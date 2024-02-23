import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/reuse/note_viewmodel.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class FlashCardViewModel with AudioViewModel, NoteViewModel {
  final ValueNotifier<String?> _indexVocabulary = ValueNotifier<String?>(null);
  ValueNotifier<String?> get indexVocabulary => _indexVocabulary;

  final ValueNotifier<bool> _canPlayGame = ValueNotifier<bool>(false);
  ValueNotifier<bool> get canPlayGame => _canPlayGame;

  var index = 0;
  var nextScreen = false;

  Future<List<Vocabulary>> vocabularies(SubTopic? subTopic) async {
    var db = getIt<DBProvider>();
    var vocabularies = subTopic?.vocabularies ??
        await db.getVocabulary(subTopic?.id.toString());
    var isCanGame =
        vocabularies.where((element) => element.isLearn == 0).isEmpty == true;
    _canPlayGame.value = isCanGame;

    // getIt<Preference>().harcodeText();

    var firstNotLearn =
        vocabularies.indexWhere((element) => element.isLearn == 0);
    index = firstNotLearn == -1 ? 0 : firstNotLearn;
    var vocabulary = vocabularies[index];
    vocabulary.isLearn = 1;
    syncVocabulary(vocabulary);
    playAudio(vocabulary.audios?.getOrNull(0));
    indexVocabulary.value = '${index + 1}/${vocabularies.length}';
    return vocabularies;
  }

  void updateIndexVocabulary(String index) {
    _indexVocabulary.value = index;
  }

  void syncVocabulary(Vocabulary? vocabulary, {bool lastItem = true}) async {
    if (_canPlayGame.value == true) return;
    var db = getIt<DBProvider>();
    vocabulary?.isLearn = 1;
    var canPlay = await db.updateAndCheckVocabulary(vocabulary);
    if (lastItem) {
      _canPlayGame.value = canPlay;
    }
  }

  bool isShowGuideLearnWithGame() {
    if (nextScreen) {
      return false;
    }
    var pref = getIt<Preference>();
    return pref.isGuideLearnWithGame();
  }
}
