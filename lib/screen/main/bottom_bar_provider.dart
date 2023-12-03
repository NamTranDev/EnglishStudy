// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentPage = 0;
  PageController _pageController = new PageController(initialPage: 0);
  PageController get pageController => this._pageController;

  int get currentPage => this._currentPage;
  set currentPage(int val) {
    this._currentPage = val;
    _pageController.animateToPage(val,
        duration: Duration(milliseconds: 1), curve: Curves.easeOut);
    notifyListeners();
  }
}
