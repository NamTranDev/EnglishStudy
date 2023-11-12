import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';

class SubTopicViewModel {
  StreamController<List<SubTopic>> _subTopicListController = StreamController();
  Stream<List<SubTopic>> get subTopicsList => _subTopicListController.stream;

  final ValueNotifier<int> _progressStatus = ValueNotifier<int>(0);
  ValueNotifier<int> get progressStatus => _progressStatus;

  Future<void> initData(String? topicId) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    var db = getIt<DBProvider>();
    List<SubTopic> topics = await db.getSubTopics(topicId);
    _subTopicListController.sink.add(topics);
  }

  Future<void> dispose() => _subTopicListController.close();

  Future<bool> syncSubTopic(String? subTopicId) async {
    var db = getIt<DBProvider>();
    return db.syncSubTopic(subTopicId);
  }

  Future<void> syncProgress(SubTopic? subTopic) async {
    var db = getIt<DBProvider>();
    subTopic?.processLearn = await db.progressSubTopic(subTopic);
    _progressStatus.value = _progressStatus.value++;
  }
}
