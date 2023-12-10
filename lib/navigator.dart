import 'package:english_study/screen/listening/conversation/conversation_screen.dart';
import 'package:english_study/screen/listening/lessions/lession_topic_screen.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:english_study/screen/vocabulary/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/vocabulary/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';

var routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  MainScreen.routeName: (context) => MainScreen(),
  TopicScreen.routeName: (context) => TopicScreen(),
  SubTopicScreen.routeName: (context) => SubTopicScreen(),
  FlashCardScreen.routeName: (context) => FlashCardScreen(),
  GameVocabularyScreen.routeName: (context) => GameVocabularyScreen(),
  LessionTopicScreen.routeName: (context) => LessionTopicScreen(),
  ConversationScreen.routeName: (context) => ConversationScreen(),
};
