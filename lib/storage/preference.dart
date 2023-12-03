// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_preferences/shared_preferences.dart';

Future<Preference> initPreference() async {
  Preference pref = Preference._();
  pref._init();
  return pref;
}

class Preference {
  Preference._();

  final _KEY_GUIDE_LEARN_WITH_GAME = 'KEY_GUIDE_LEARN_WITH_GAME';
  final _KEY_CATEGORY_VOCABULARY_CURRENT = 'KEY_CATEGORY_VOCABULARY_CURRENT';

  SharedPreferences? _prefs;

  Future _init() async => _prefs = await SharedPreferences.getInstance();

  bool isGuideLearnWithGame() {
    var isGuideLearnWithGame =
        _prefs?.getBool(_KEY_GUIDE_LEARN_WITH_GAME) ?? true;
    print(isGuideLearnWithGame);
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, false);
    return isGuideLearnWithGame;
  }

  String? currentCategory() {
    return _prefs?.getString(_KEY_CATEGORY_VOCABULARY_CURRENT);
  }

  void setCurrentCategory(String? category) {
    if (category == null) return;
    _prefs?.setString(_KEY_CATEGORY_VOCABULARY_CURRENT, category);
  }

  void harcodeText() {
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, true);
  }
}
