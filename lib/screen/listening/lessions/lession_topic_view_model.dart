import 'package:english_study/constants.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/complete_category_view_model.dart';
import 'package:english_study/reuse/lessions_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';

class LessionTopicViewModel extends LessionsViewModel
    with CompleteCategoryViewModel {
  Future<List<Conversation>> initData(Topic? topic, bool fromTab) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    List<Conversation> conversations = await getData(topic, fromTab);
    if (fromTab) checkCompleteWithTopic(topic);
    return conversations;
  }

  Future<List<Conversation>> getData(Topic? topic, bool fromTab) async {
    var db = getIt<DBProvider>();
    var iPref = getIt<Preference>();
    var isHasResource = downloadManager.checkHasResource(topic?.link_resource);
    List<Conversation> conversations = await db.getConversations(
        topic?.id?.toString(),
        iPref.isConversationBackground() && isHasResource);
    return conversations;
  }

  @override
  Future<bool> syncLession(String? id) async {
    var db = getIt<DBProvider>();
    return await db.checkConversationLearn(id);
  }

  Future<void> updateComplete(
      List<Conversation>? conversations, int index, Topic? topic) async {
    Conversation? conversation = conversations?.getOrNull(index);
    conversation?.isLearnComplete = 1;

    if ((index + 1) < (conversations?.length ?? 0)) {
      Conversation? nextSubTopic = conversations?.getOrNull(index + 1);
      nextSubTopic?.isLearning = 1;
    }

    updateStatus();

    checkCompleteWithTopic(topic);
  }
}
