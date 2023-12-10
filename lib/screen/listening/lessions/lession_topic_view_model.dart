import 'package:english_study/constants.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/reuse/lessions_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

class LessionTopicViewModel extends LessionsViewModel{

  Future<List<Conversation>> initData(String? topicId) async {
    await Future.delayed(Duration(milliseconds: duration_animation_screen));
    var db = getIt<DBProvider>();
    List<Conversation> conversations = await db.getConversations(topicId);
    return conversations;
  }
  
  @override
  Future<bool> syncLession(String? id) async {
    var db = getIt<DBProvider>();
    return await db.syncTopicConversation(id);
  }

  Future<void> updateComplete(
      List<Conversation>? conversations, int index) async {
    Conversation? conversation = conversations?[index];
    conversation?.isLearnComplete = 1;

    if ((index + 1) < (conversations?.length ?? 0)) {
      Conversation? nextSubTopic = conversations?[index + 1];
      nextSubTopic?.isLearning = 1;
    }
    updateStatus();
  }
}