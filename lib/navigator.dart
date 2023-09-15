import 'package:english_study/screen/category/category_screen.dart';
import 'package:english_study/screen/flash_card/flash_card_screen.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  CategoryScreen.routeName: (context) => CategoryScreen(),
  TopicScreen.routeName: (context) => TopicScreen(),
  SubTopicScreen.routeName: (context) => SubTopicScreen(),
  FlashCardScreen.routeName: (context) => FlashCardScreen(),
};