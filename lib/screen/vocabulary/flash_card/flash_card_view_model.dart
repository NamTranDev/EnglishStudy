import 'package:english_study/model/audio.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class FlashCardViewModel with AudioViewModel {
  final ValueNotifier<String?> _indexVocabulary = ValueNotifier<String?>(null);
  ValueNotifier<String?> get indexVocabulary => _indexVocabulary;

  final ValueNotifier<bool> _canPlayGame = ValueNotifier<bool>(false);
  ValueNotifier<bool> get canPlayGame => _canPlayGame;

  var index = 0;
  var nextScreen = false;

  Future<List<Vocabulary>> vocabularies(String? sub_topic_id) async {
    var db = getIt<DBProvider>();
    var vocabularies = await db.getVocabulary(sub_topic_id);
    var isCanGame =
        vocabularies.where((element) => element.isLearn == 0).isEmpty == true;
    _canPlayGame.value = isCanGame;

    // getIt<Preference>().harcodeText();

    var firstNotLearn =
        vocabularies.indexWhere((element) => element.isLearn == 0);
    index = firstNotLearn == -1 ? 0 : firstNotLearn;
    var vocabulary = vocabularies[index];
    vocabulary.isLearn = 1;
    updateVocabulary(vocabulary);
    playAudio(vocabulary.audios?.getOrNull(0));
    indexVocabulary.value = '${index + 1}/${vocabularies.length}';
    return vocabularies;
  }

  void updateIndexVocabulary(String index) {
    _indexVocabulary.value = index;
  }

  void updateVocabulary(Vocabulary? vocabulary) async {
    if (_canPlayGame.value == true) return;
    var db = getIt<DBProvider>();
    vocabulary?.isLearn = 1;
    _canPlayGame.value = await db.updateVocabulary(vocabulary);
  }

  bool isShowGuideLearnWithGame() {
    if (nextScreen) {
      return false;
    }
    var pref = getIt<Preference>();
    return pref.isGuideLearnWithGame();
  }
}
