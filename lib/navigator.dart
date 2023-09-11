import 'package:english_study/screen/flash_card/flash_card_screen.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  FlashCardScreen.routeName: (context) => FlashCardScreen(),
};