import 'dart:async';
import 'dart:io';

import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TopicViewModel {
  final ValueNotifier<int> _updateLessionStatus = ValueNotifier<int>(0);
  ValueNotifier<int> get updateLessionStatus => _updateLessionStatus;

  final ValueNotifier<bool> _needDownload = ValueNotifier<bool>(false);
  ValueNotifier<bool> get needDownload => _needDownload;

  final DownloadManager _downloadManager = getIt<DownloadManager>();
  DownloadManager get downloadManager => _downloadManager;

  Future<List<Topic>> initData(String? category) async {
    await Future.delayed(Duration(milliseconds: 2 * duration_animation_screen));
    var db = getIt<DBProvider>();
    List<Topic> topics = await db.getTopics(category);

    var isNeedDownload = topics.where((element) => element.isDownload == false).firstOrNull != null;
    _needDownload.value = isNeedDownload;
    if (isNeedDownload) {
      String category = getIt<Preference>().catabularyVocabularyCurrent();
      final path = (await getTemporaryDirectory()).path;
      var directory =
          Directory("${getIt<AppMemory>().pathFolderDocument}/${category}");
      if (await directory.exists() == false) {
        await directory.create();
      }
      getIt<DownloadManager>().initFileInfos(
          category,
          topics
              .map(
                (e) => FileInfo(
                    e.link_resource, "${path}/${e.name}.zip", directory.path,
                    status: e.isDownload
                        ? DownloadStatus.COMPLETE
                        : DownloadStatus.NONE),
              )
              .toList());
    }
    return topics;
  }

  Future<void> syncTopic(Topic? topic) async {
    var db = getIt<DBProvider>();
    if (await db.syncTopic(topic?.id?.toString())) {
      _updateLessionStatus.value = _updateLessionStatus.value++;
    }
  }

  void downloadAll() async {
    await _downloadManager.downloadAll();
    // _needDownload.value = false;
  }

  void downloadTopic(FileInfo fileInfo) async {
    await _downloadManager.download(fileInfo.link);
    _needDownload.value = _downloadManager.checkNeedDownload();
  }
}
