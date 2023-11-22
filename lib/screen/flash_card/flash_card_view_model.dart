import 'package:english_study/model/audio.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

class FlashCardViewModel with AudioViewModel {
  Future<List<Vocabulary>> vocabularies(String? sub_topic_id) async {
    var db = getIt<DBProvider>();
    var vocabularies = await db.getVocabulary(sub_topic_id);
    playAudio(vocabularies[0].audios?[0]);
    return vocabularies;
  }

  void updateVocabulary(Vocabulary? vocabulary) {
    var db = getIt<DBProvider>();
    vocabulary?.isLearn = 1;
    db.updateVocabulary(vocabulary);
  }
}
