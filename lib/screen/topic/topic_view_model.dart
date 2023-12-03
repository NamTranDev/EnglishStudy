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

  Future<List<Topic>> initData(String? category, List<Topic>? topics) async {
    await Future.delayed(Duration(milliseconds: 2 * duration_animation_screen));
    var db = getIt<DBProvider>();

    topics ??= await db.getTopics(category);

    _downloadManager.checkNeedDownload(category, topics,
        onSyncUI: (needDownload) {
      _needDownload.value = needDownload;
    });

    return topics;
  }

  void dispose() {
    _downloadManager.onNeedDownloadListener = null;
    _downloadManager.onDownloadErrorListener = null;
  }

  Future<void> syncTopic(Topic? topic) async {
    var db = getIt<DBProvider>();
    if (await db.syncTopic(topic?.id?.toString())) {
      _updateLessionStatus.value = _updateLessionStatus.value++;
    }
  }

  void downloadAll() async {
    _downloadManager.downloadAll();
  }

  void downloadTopic(FileInfo? fileInfo) async {
    _downloadManager.download(fileInfo?.link);
  }
}
