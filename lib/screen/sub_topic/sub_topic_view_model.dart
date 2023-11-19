import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';

class SubTopicViewModel {
  final ValueNotifier<int> _updateLessionStatus = ValueNotifier<int>(0);
  ValueNotifier<int> get updateLessionStatus => _updateLessionStatus;

  final ValueNotifier<bool> _isDownloaded = ValueNotifier<bool>(false);
  ValueNotifier<bool> get isDownloaded => _isDownloaded;

  Future<List<SubTopic>> initData(String? topicId) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    var db = getIt<DBProvider>();
    List<SubTopic> topics = await db.getSubTopics(topicId);
    return topics;
  }

  Future<bool> syncSubTopic(String? subTopicId) async {
    var db = getIt<DBProvider>();
    return db.syncSubTopic(subTopicId);
  }

  Future<void> syncProgress(SubTopic? subTopic) async {
    var db = getIt<DBProvider>();
    subTopic?.processLearn = await db.progressSubTopic(subTopic);
    _updateLessionStatus.value = _updateLessionStatus.value++;
  }

  Future<void> updateSubTopicComplete(
      List<SubTopic>? subTopics, int index) async {
    SubTopic? subTopic = subTopics?[index];
    subTopic?.isLearnComplete = 1;
    subTopic?.processLearn = 100;

    if ((index + 1) < (subTopics?.length ?? 0)) {
      SubTopic? nextSubTopic = subTopics?[index + 1];
      nextSubTopic?.isLearning = 1;
    }
    _updateLessionStatus.value = _updateLessionStatus.value++;
  }
}
