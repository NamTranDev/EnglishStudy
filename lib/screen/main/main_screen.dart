import 'package:english_study/ad_helper.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/model/bottom_bar_item.dart';
import 'package:english_study/reuse/component/banner_component.dart';
import 'package:english_study/screen/main/bottom_bar_provider.dart';
import 'package:english_study/screen/main/main_viewmodel.dart';
import 'package:english_study/screen/main/tab/complete/complete_tab_viewmodel.dart';
import 'package:english_study/screen/main/tab/listen/listen_tab_viewmodel.dart';
import 'package:english_study/screen/main/tab/setting/setting_tab_viewmodel.dart';
import 'package:english_study/screen/main/tab/vocabulary/vocabulary_tab_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  static String routeName = '/main';
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => MainViewModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BottomNavigationBarProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => VocabularyTabViewModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ListenTabViewModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CompleteTabViewModel(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SettingTabViewModel(),
        ),
      ],
      child: Container(
        color: Colors.white,
        child: Consumer<MainViewModel>(
          builder: (context, viewmodel, _) {
            return Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                      future: viewmodel.checkTab(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "Something wrong with message: ${snapshot.error.toString()}"),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return ChangeNotifierProvider<
                              BottomNavigationBarProvider>(
                            create: (context) => BottomNavigationBarProvider(),
                            builder: (context, child) =>
                                bodyMain(context, viewmodel),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                BannerComponent()
              ],
            );
          },
        ),
      ),
    );
  }

  Widget bodyMain(BuildContext context, MainViewModel viewModel) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: provider.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: viewModel.pages,
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
          items: bottomBarItems(viewModel.bottomBars, provider),
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
