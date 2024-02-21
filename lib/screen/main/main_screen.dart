import 'package:english_study/constants.dart';
import 'package:english_study/model/bottom_bar_item.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/screen/main/bottom_bar_provider.dart';
import 'package:english_study/screen/main/tab/complete/complete_tab.dart';
import 'package:english_study/screen/main/tab/listen/listening_tab.dart';
import 'package:english_study/screen/main/tab/setting/setting_tab.dart';
import 'package:english_study/screen/main/tab/vocabulary/vocabulary_tab.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/sync_data/background_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> _pages = [];
  late List<BottomBarItem> _bottomBars = [];

  @override
  void initState() {
    super.initState();
    syncDataBackgroundTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: checkTab(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Something wrong with message: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                return ChangeNotifierProvider<BottomNavigationBarProvider>(
                  create: (context) => BottomNavigationBarProvider(),
                  builder: (context, child) => bodyMain(context),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Future<void> checkTab() async {
    var db = getIt<DBProvider>();
    var isHasVocabularyTab =
        await db.hasCategoryToLearn(TabType.VOCABULARY.value);
    var isHasListenTab = await db.hasCategoryToLearn(TabType.LISTEN.value);
    var isCompleteTab = await db.hasCategoryLearnComplete();
    print('isHasVocabularyTab : ' + isHasVocabularyTab.toString());
    print('isHasListenTab : ' + isHasListenTab.toString());
    print('isCompleteTab : ' + isCompleteTab.toString());
    _pages.clear();
    _bottomBars.clear();
    _pages.add(SettingTab());
    _bottomBars.add(
        BottomBarItem(icon: 'assets/icons/ic_setting.svg', lable: 'Setting'));
    if (isCompleteTab) {
      _pages.insert(0, CompleteTab());
      _bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_learned.svg', lable: 'Complete'));
    }
    if (isHasListenTab) {
      _pages.insert(0, ListenerTab());
      _bottomBars.insert(0,
          BottomBarItem(icon: 'assets/icons/ic_listen.svg', lable: 'Listen'));
    }
    if (isHasVocabularyTab) {
      _pages.insert(0, VocabularyTab());
      _bottomBars.insert(
          0,
          BottomBarItem(
              icon: 'assets/icons/ic_vocabulary.svg', lable: 'Vocabulary'));
    }

    var tabPrevious = getIt<AppMemory>().currentTab;

    if (tabPrevious == TabType.LISTEN.value && !isHasListenTab) {
      getIt<AppMemory>().currentTab = null;
    }
  }

  Widget bodyMain(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: provider.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: maastricht_blue.withOpacity(0.5), blurRadius: 3.0),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 10.0,
          items: bottomBarItems(_bottomBars, provider),
          currentIndex: provider.currentPage,
          selectedItemColor: maastricht_blue,
          unselectedItemColor: maastricht_blue.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: (index) {
            if (index != provider.currentPage) {
              provider.currentPage = index;
            }
          },
        ),
      ),
    );
  }

  bottomBarItems(
      List<BottomBarItem> bottomBars, BottomNavigationBarProvider provider) {
    List<BottomNavigationBarItem> items = [];
    for (int i = 0; i < bottomBars.length; i++) {
      BottomBarItem item = bottomBars[i];
      items.add(BottomNavigationBarItem(
        icon: SvgPicture.asset(
          item.icon,
          width: 30,
          height: 30,
          color: provider.currentPage == i
              ? maastricht_blue
              : maastricht_blue.withOpacity(0.5),
        ),
        label: item.lable,
        // backgroundColor: Colors.red,
      ));
    }
    return items;
  }
}
