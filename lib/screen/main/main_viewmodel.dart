import 'package:english_study/constants.dart';
import 'package:english_study/localization/generated/l10n.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/bottom_bar_item.dart';
import 'package:english_study/model/topic_type.dart';
import 'package:english_study/screen/main/tab/complete/complete_tab.dart';
import 'package:english_study/screen/main/tab/listen/listening_tab.dart';
import 'package:english_study/screen/main/tab/setting/setting_tab.dart';
import 'package:english_study/screen/main/tab/vocabulary/vocabulary_tab.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:flutter/cupertino.dart';

class MainViewModel with ChangeNotifier {
  late List<Widget> pages = [];
  late List<BottomBarItem> bottomBars = [];

  Future<void> checkTab() async {
    await Future.delayed(
        const Duration(milliseconds: 2 * duration_animation_screen));

    var db = getIt<DBProvider>();
    var isHasVocabularyTab =
        await db.hasCategoryToLearn(TopicType.VOCABULARY.value);
    var isHasListenTab = await db.hasCategoryToLearn(TopicType.LISTEN.value);
    var isCompleteTab = await db.hasCategoryLearnComplete();
    var localize = getIt<Localize>();
    logger('isHasVocabularyTab : $isHasVocabularyTab');
    logger('isHasListenTab : $isHasListenTab');
    logger('isCompleteTab : $isCompleteTab');
    pages.clear();
    bottomBars.clear();
    pages.add(const SettingTab());
    bottomBars.add(
        BottomBarItem(icon: 'assets/icons/ic_setting.svg', lable: localize.main_screen_tab_setting_title));
    if (isCompleteTab) {
      pages.insert(0, const CompleteTab());
      bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_learned.svg', lable: localize.main_screen_tab_complete_title));
    }
    if (isHasListenTab) {
      pages.insert(0, const ListenerTab());
      bottomBars.insert(0,
          BottomBarItem(icon: 'assets/icons/ic_listen.svg', lable: localize.main_screen_tab_listen_title));
    }
    if (isHasVocabularyTab) {
      pages.insert(0, const VocabularyTab());
      bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_vocabulary.svg', lable: localize.main_screen_tab_vocabulary_title));
    }

    var tabPrevious = getIt<AppMemory>().currentTab;

    if (tabPrevious == TopicType.LISTEN.value && !isHasListenTab) {
      getIt<AppMemory>().currentTab = null;
    }
  }
}
