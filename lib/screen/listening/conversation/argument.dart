import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/topic.dart';

class ScreenConversationArguments {
  final List<Conversation>? conversations;
  final Conversation? conversation;

  ScreenConversationArguments(this.conversations, this.conversation);
}
