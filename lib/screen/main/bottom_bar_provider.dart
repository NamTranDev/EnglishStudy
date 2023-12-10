// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentPage = 0;
  PageController _pageController = new PageController(initialPage: 0);
  PageController get pageController => this._pageController;

  int get currentPage => this._currentPage;
  set currentPage(int tab) {
    this._currentPage = tab;
    getIt<DownloadManager>().refresh(getIt<Preference>().currentCategory(tab));
    _pageController.animateToPage(tab,
        duration: Duration(milliseconds: 1), curve: Curves.easeOut);
    notifyListeners();
  }
}
