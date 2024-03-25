import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/reuse/complete_category_view_model.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class TopicViewModel with CompleteCategoryViewModel {
  final ValueNotifier<int> _updateLessionStatus = ValueNotifier<int>(0);
  ValueNotifier<int> get updateLessionStatus => _updateLessionStatus;

  final ValueNotifier<bool> _needDownload = ValueNotifier<bool>(false);
  ValueNotifier<bool> get needDownload => _needDownload;

  final DownloadManager _downloadManager = getIt<DownloadManager>();
  DownloadManager get downloadManager => _downloadManager;

  Future<List<Topic>> initData(
      String? category, List<Topic>? topics, int? type) async {
    await Future.delayed(
        const Duration(milliseconds: 2 * duration_animation_screen));

    var db = getIt<DBProvider>();

    topics ??= await db.getTopics(category, type);

    checkCompleteWithTopics(topics);

    downloadManager.onNeedDownloadListener = (value) {
      logger(value);
      _needDownload.value = value;
    };
    downloadManager.checkNeedDownload(category, topics);

    return topics;
  }

  Future<void> syncTopic(List<Topic>? topics, int index) async {
    Topic? topic = topics?.getOrNull(index);
    var db = getIt<DBProvider>();
    if (await db.syncTopic(topic?.id?.toString())) {
      topic?.isLearnComplete = 1;

      if (topics?.length == 1) {
        showCompleteUI(true);
      } else {
        if ((index + 1) < (topics?.length ?? 0)) {
          Topic? nextSubTopic = topics?.getOrNull(index + 1);
          nextSubTopic?.isLearning = 1;
          _updateLessionStatus.value = _updateLessionStatus.value++;
        } else {
          showCompleteUI(true);
        }
      }
    }
  }

  void downloadAll() async {
    _downloadManager.downloadAll();
  }

  void downloadTopic(FileInfo? fileInfo) async {
    _downloadManager.download(fileInfo?.link);
  }
}
