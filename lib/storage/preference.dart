// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:english_study/logger.dart';
import 'package:english_study/notification/notification_model.dart';
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
  final _KEY_GUIDE_NOTE = 'KEY_GUIDE_NOTE';
  final _KEY_CATEGORY_CURRENT = 'KEY_CATEGORY_CURRENT_';
  final _KEY_CONVERSATION_BACKGROUND = 'KEY_CONVERSATION_BACKGROUND';
  final _KEY_DAILY_NOTIFICATION = 'KEY_DAILY_NOTIFICATION';
  final _KEY_VERSION_UPDATE = 'KEY_VERSION_UPDATE';

  SharedPreferences? _prefs;

  Future _init() async => _prefs = await SharedPreferences.getInstance();

  bool isGuideLearnWithGame() {
    var isGuideLearnWithGame =
        _prefs?.getBool(_KEY_GUIDE_LEARN_WITH_GAME) ?? true;
    print(isGuideLearnWithGame);
    _prefs?.setBool(_KEY_GUIDE_LEARN_WITH_GAME, false);
    return isGuideLearnWithGame;
  }

  bool isGuideNote() {
    var isGuideNote = _prefs?.getBool(_KEY_GUIDE_NOTE) ?? true;
    print(isGuideNote);
    _prefs?.setBool(_KEY_GUIDE_NOTE, false);
    return isGuideNote;
  }

  bool isGuideNextCategory() {
    var isGuideNextCategory = _prefs?.getBool(_KEY_GUIDE_NEXT_CATEGORY) ?? true;
    print(isGuideNextCategory);
    _prefs?.setBool(_KEY_GUIDE_NEXT_CATEGORY, false);
    return isGuideNextCategory;
  }

  bool isConversationBackground() {
    var isConversationBackground =
        _prefs?.getBool(_KEY_CONVERSATION_BACKGROUND) ?? false;
    logger(isConversationBackground);
    return isConversationBackground;
  }

  void setConversationBackground(bool isConversationBackground) {
    _prefs?.setBool(_KEY_CONVERSATION_BACKGROUND, isConversationBackground);
  }

  String? currentCategory(int? type) {
    return _prefs?.getString(_KEY_CATEGORY_CURRENT + (type?.toString() ?? ''));
  }

  void saveDailyNotification(NotificationModel model) {
    _prefs?.setString(_KEY_DAILY_NOTIFICATION, model.toJson());
  }

  int versionUpdate() {
    return _prefs?.getInt(_KEY_VERSION_UPDATE) ?? 0;
  }

  void saveVersionUpdate(int? version) {
    _prefs?.setInt(_KEY_VERSION_UPDATE, version ?? 0);
  }

  NotificationModel dailyNotification() {
    String? value = _prefs?.getString(_KEY_DAILY_NOTIFICATION);
    if (value == null || value.isEmpty) {
      return NotificationModel(
          idNotification: 1,
          hour: 20,
          minute: 30,
          isEnable: true,
          isSchedule: false);
    }
    return NotificationModel.fromJson(value);
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
