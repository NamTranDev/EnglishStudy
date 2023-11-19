import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/memory.dart';
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
    var isNeedDownload = topics.firstWhere(
            (element) => element.isDownload == false,
            orElse: null) !=
        null;
    _needDownload.value = isNeedDownload;
    if (isNeedDownload) {
      String category = getIt<Preference>().catabularyVocabularyCurrent();
      final path = (await getTemporaryDirectory()).path;
      getIt<DownloadManager>().initFileInfos(
          category,
          topics
              .map((e) => FileInfo(e.link_resource, "${path}/${e.name}.zip",
                  "${getIt<AppMemory>().pathFolderDocument}/${category}/${e.name}"))
              .toList());
    }
    return topics;
  }

  Future<void> syncTopic(String? topicId) async {
    var db = getIt<DBProvider>();
    if (await db.syncTopic(topicId)) {
      _updateLessionStatus.value = _updateLessionStatus.value++;
    }
  }

  void downloadAll() async {
    await _downloadManager.downloadAll();
    _needDownload.value = false;
  }
}
