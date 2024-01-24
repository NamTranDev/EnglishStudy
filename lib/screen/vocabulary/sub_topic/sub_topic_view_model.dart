import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/complete_category_view_model.dart';
import 'package:english_study/reuse/lessions_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SubTopicViewModel extends LessionsViewModel
    with CompleteCategoryViewModel {
  Future<void>? _syncFuture;
  bool _isDispose = false;

  Future<List<SubTopic>> initData(Topic? topic, bool fromTab) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    var db = getIt<DBProvider>();
    List<SubTopic> subTopics = await db.getSubTopics(topic?.id?.toString());
    syncVocabularies(subTopics,db);
    if (fromTab) checkCompleteWithTopic(topic);
    return subTopics;
  }

  Future<void> syncVocabularies(List<SubTopic> subTopics,DBProvider db) async {
    _syncFuture = _syncVocabulariesInIsolate(subTopics,db);
    await _syncFuture;
  }

  Future<void> _syncVocabulariesInIsolate(
      List<SubTopic> subTopics, DBProvider db) async {
    try {
      await Future.forEach(subTopics, (SubTopic subTopic) async {
        await syncVocabulariesInBackground(subTopic, db);
      });
    } on FlutterError catch (e) {
      print(e.message);
      // Handle FlutterError to identify when the widget is disposed
      if (e.stackTrace.toString().contains('setState')) {
        print('Widget disposed during background sync');
      }
    }
  }

  Future<void> syncVocabulariesInBackground(
      SubTopic subTopic, DBProvider db) async {
    if (_isDispose) {
      return;
    }
    List<Vocabulary> vocabularies = await compute(_syncVocabularies,
        {'subTopicId': subTopic.id.toString(), 'dbProvider': db});
    print(vocabularies);
    print(_isDispose);
    if (_isDispose) {
      return;
    }
    subTopic.vocabularies = vocabularies;
  }

  static Future<List<Vocabulary>> _syncVocabularies(
      Map<String, dynamic> data) async {
    var subTopicId = data['subTopicId'];
    var db = data['dbProvider'] as DBProvider;
    return await db.getVocabulary(subTopicId);
  }

  @override
  Future<bool> syncLession(String? id) async {
    var db = getIt<DBProvider>();
    return await db.syncSubTopic(id);
  }

  Future<void> syncProgress(SubTopic? subTopic) async {
    var db = getIt<DBProvider>();
    subTopic?.processLearn = await db.progressSubTopic(subTopic);
    updateStatus();
  }

  Future<void> updateComplete(
      List<SubTopic>? subTopics, int index, Topic? topic) async {
    SubTopic? subTopic = subTopics?.getOrNull(index);
    subTopic?.isLearnComplete = 1;
    subTopic?.processLearn = 100;

    if ((index + 1) < (subTopics?.length ?? 0)) {
      SubTopic? nextSubTopic = subTopics?.getOrNull(index + 1);
      nextSubTopic?.isLearning = 1;
    }
    updateStatus();
    checkCompleteWithTopic(topic);
  }

  void dispose() {
    _isDispose = true;
  }
}
