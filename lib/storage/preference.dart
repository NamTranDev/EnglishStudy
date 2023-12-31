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
  final _KEY_GUIDE_NEXT_CATEGORY = 'KEY_GUIDE_NEXT_CATEGORY';
  final _KEY_CATEGORY_CURRENT = 'KEY_CATEGORY_CURRENT_';

  SharedPreferences? _prefs;

  Future _init() async => _prefs = await SharedPreferences.getInstance();

  bool isGuideLearnWithGame() {
    var isGuideLearnWithGame =
        _prefs?.getBool(_KEY_GUIDE_LEARN_WITH_GAME) ?? true;
    print(isGuideLearnWithGame);
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, false);
    return isGuideLearnWithGame;
  }

  bool isGuideNextCategory() {
    var isGuideNextCategory =
        _prefs?.getBool(_KEY_GUIDE_NEXT_CATEGORY) ?? true;
    print(isGuideNextCategory);
    _prefs?.setBool(_KEY_GUIDE_NEXT_CATEGORY, false);
    return isGuideNextCategory;
  }

  String? currentCategory(int? type) {
    return _prefs?.getString(_KEY_CATEGORY_CURRENT + (type?.toString() ?? ''));
  }

  void setCurrentCategory(int? type, String? category) {
    if (category == null) {
      _prefs?.remove(_KEY_CATEGORY_CURRENT + (type?.toString() ?? ''));
      return;
    }
    _prefs?.setString(
        _KEY_CATEGORY_CURRENT + (type?.toString() ?? ''), category);
  }

  void harcodeText() {
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, true);
  }
}
