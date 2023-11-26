// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_preferences/shared_preferences.dart';

Future<Preference> initPreference() async {
  Preference pref = Preference._();
  pref._init();
  return pref;
}

class Preference {
  Preference._();

  final _KEY_CATEGORY_VOCABULARY_SELECT = 'KEY_CATEGORY_VOCABULARY_SELECT';
  final _KEY_GUIDE_LEARN_WITH_GAME = 'KEY_GUIDE_LEARN_WITH_GAME';

  SharedPreferences? _prefs;

  Future _init() async => _prefs = await SharedPreferences.getInstance();

  String catabularyVocabularyCurrent() {
    return _prefs?.getString(_KEY_CATEGORY_VOCABULARY_SELECT) ??
        'CEFR_Wordlist';
  }

  bool isGuideLearnWithGame() {
    var isGuideLearnWithGame =
        _prefs?.getBool(_KEY_GUIDE_LEARN_WITH_GAME) ?? true;
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, false);
    return isGuideLearnWithGame;
  }
}
