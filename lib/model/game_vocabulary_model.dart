// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/vocabulary.dart';

class GameVocabularyModel {
  final Vocabulary main;
  final List<Vocabulary> vocabularies;
  GameType? type;

  GameVocabularyModel({
    required this.main,
    required this.vocabularies,
  });
}
