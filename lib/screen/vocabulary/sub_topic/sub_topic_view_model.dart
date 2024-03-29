import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/complete_category_view_model.dart';
import 'package:english_study/reuse/lessions_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';

class SubTopicViewModel extends LessionsViewModel
    with CompleteCategoryViewModel {
  Future<List<SubTopic>> initData(Topic? topic, bool fromTab) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    var db = getIt<DBProvider>();
    List<SubTopic> subTopics = await db.getSubTopics(topic?.id?.toString());
    if (fromTab) checkCompleteWithTopic(topic);
    return subTopics;
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
}
