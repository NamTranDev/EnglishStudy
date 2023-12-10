import 'package:english_study/model/conversation.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

class ConversationViewModel with AudioViewModel {
  Future<Conversation> conversationDetail(String? id) async {
    var db = getIt<DBProvider>();
    return db.getConversationDetail(id);
  }
}
