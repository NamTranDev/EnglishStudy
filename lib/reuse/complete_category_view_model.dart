import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

mixin CompleteCategoryViewModel {
  final ValueNotifier<bool> _showComplete = ValueNotifier<bool>(false);
  ValueNotifier<bool> get showComplete => _showComplete;

  Function? onShowGuideNextCategory;

  void checkCompleteWithTopics(List<Topic>? topics) async {
    var db = getIt<DBProvider>();

    var numberTopicLearn =
        topics?.where((element) => element.isLearnComplete == 0).length == 1;

    if (numberTopicLearn) {
      showCompleteUI(
          await db.checkTopicComplete(topics?.getOrNull(topics.length - 1)));
    }
  }

  void checkCompleteWithTopic(Topic? topic) async {
    var db = getIt<DBProvider>();
    var isComplete = await db.checkCategory(topic);
    showCompleteUI(isComplete);
  }

  void showCompleteUI(bool isComplete) {
    _showComplete.value = isComplete;
    if (isComplete) showGuideNextCategory();
  }

  void showGuideNextCategory() {
    var isGuideNextCategory = getIt<Preference>().isGuideNextCategory();
    if (isGuideNextCategory) {
      Future.delayed(Duration(milliseconds: 10)).then((value) {
        onShowGuideNextCategory?.call();
      });
    }
  }
}
