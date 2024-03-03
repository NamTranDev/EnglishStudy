import 'package:english_study/model/bottom_bar_item.dart';
import 'package:english_study/model/tab_type.dart';
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
    var db = getIt<DBProvider>();
    var isHasVocabularyTab =
        await db.hasCategoryToLearn(TopicType.VOCABULARY.value);
    var isHasListenTab = await db.hasCategoryToLearn(TopicType.LISTEN.value);
    var isCompleteTab = await db.hasCategoryLearnComplete();
    print('isHasVocabularyTab : ' + isHasVocabularyTab.toString());
    print('isHasListenTab : ' + isHasListenTab.toString());
    print('isCompleteTab : ' + isCompleteTab.toString());
    pages.clear();
    bottomBars.clear();
    pages.add(SettingTab());
    bottomBars.add(
        BottomBarItem(icon: 'assets/icons/ic_setting.svg', lable: 'Setting'));
    if (isCompleteTab) {
      pages.insert(0, CompleteTab());
      bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_learned.svg', lable: 'Complete'));
    }
    if (isHasListenTab) {
      pages.insert(0, ListenerTab());
      bottomBars.insert(0,
          BottomBarItem(icon: 'assets/icons/ic_listen.svg', lable: 'Listen'));
    }
    if (isHasVocabularyTab) {
      pages.insert(0, VocabularyTab());
      bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_vocabulary.svg', lable: 'Vocabulary'));
    }

    var tabPrevious = getIt<AppMemory>().currentTab;

    if (tabPrevious == TopicType.LISTEN.value && !isHasListenTab) {
      getIt<AppMemory>().currentTab = null;
    }
  }
}
