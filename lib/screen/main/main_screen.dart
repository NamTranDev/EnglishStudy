import 'package:english_study/constants.dart';
import 'package:english_study/screen/main/bottom_bar_provider.dart';
import 'package:english_study/screen/main/tab/listen/listening_tab.dart';
import 'package:english_study/screen/main/tab/setting_tab.dart';
import 'package:english_study/screen/main/tab/vocabulary/vocabulary_tab.dart';
import 'package:flutter/cupertino.dart';
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
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [VocabularyTab(), ListenerTab(), SettingTab()];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavigationBarProvider>(
        create: (context) => BottomNavigationBarProvider(),
        builder: (context, child) => bodyMain(context));
  }

  Widget bodyMain(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    var sizeIcon = 30.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: provider.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10.0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_vocabulary.svg',
              width: sizeIcon,
              height: sizeIcon,
              color: provider.currentPage == 0
                  ? maastricht_blue
                  : maastricht_blue.withOpacity(0.5),
            ),
            label: 'Vocabulary',
            // backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_listen.svg',
              width: sizeIcon,
              height: sizeIcon,
              color: provider.currentPage == 1
                  ? maastricht_blue
                  : maastricht_blue.withOpacity(0.5),
            ),
            label: 'Listen',
            // backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ic_setting.svg',
              width: sizeIcon,
              height: sizeIcon,
              color: provider.currentPage == 2
                  ? maastricht_blue
                  : maastricht_blue.withOpacity(0.5),
            ),
            label: 'Setting',
            // backgroundColor: Colors.pink,
          ),
        ],
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
    );
  }
}
