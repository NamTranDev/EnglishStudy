import 'package:english_study/screen/category/category_screen.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:flutter/widgets.dart';

var routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  CategoryScreen.routeName: (context) => CategoryScreen(),
  TopicScreen.routeName: (context) => TopicScreen(),
  SubTopicScreen.routeName: (context) => SubTopicScreen(),
  FlashCardScreen.routeName: (context) => FlashCardScreen(),
  GameVocabularyScreen.routeName: (context) => GameVocabularyScreen(),
};