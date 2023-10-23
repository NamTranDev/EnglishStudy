import 'dart:async';
import 'dart:math';

import 'package:english_study/model/game_answer_status.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';

import '../../model/example.dart';

class GameVocabularyViewModel {
  final String? subTopicId;

  final ValueNotifier<GameVocabularyModel?> _vocabulary =
      ValueNotifier<GameVocabularyModel?>(null);
  ValueNotifier<GameVocabularyModel?> get vocabulary => _vocabulary;

  final ValueNotifier<GameAnswerStatus> _gameAnswerStatus =
      ValueNotifier<GameAnswerStatus>(GameAnswerStatus());
  ValueNotifier<GameAnswerStatus> get gameAnswerStatus => _gameAnswerStatus;

  List<GameVocabularyModel>? _listGameVocabulary;
  List<GameAnswerStatus>? _listGameAnswerStatus;
  int _index = 0;

  GameVocabularyViewModel(this.subTopicId) {
    getData();
  }

  StreamController<List<GameVocabularyModel>> _gameVocabularyListController =
      StreamController();

  Stream<List<GameVocabularyModel>> get gameVocabularyList =>
      _gameVocabularyListController.stream;

  Future<void> getData() async {
    _gameVocabularyListController.sink.add([]);
    var db = getIt<DBProvider>();
    _listGameVocabulary = subTopicId == null
        ? await db.vocabularyGameLearn()
        : await db.vocabularyGameSubTopic(subTopicId!);
    _listGameVocabulary?.forEach((element) {
      int count = 2;
      if ((element.main.audios?.length ?? 0) > 0) {
        count += 2;
      }
      if ((element.main.spellings?.length ?? 0) > 0) {
        count += 4;
      }
      if ((element.main.examples?.length ?? 0) > 0) {
        element.main.examples?.shuffle();
        for (Example? example in element.main.examples ?? []) {
          if (example == null || element.main.word == null) break;
          if (example.sentence?.contains(element.main.word!) == true) {
            count += 2;
            break;
          }
        }
      }
      var type = randomGameType(count: count);
      element.type = type;
    });
    _listGameAnswerStatus = [];
    // await Future.delayed(Duration(seconds: 2));
    // _gameVocabularies = _gameVocabularies?.sublist(0, 2);
    if (_listGameVocabulary == null)
      _gameVocabularyListController.sink.addError("Not found list Vocabulary");
    else {
      _index = 0;
      _initQuestionInfo();
      _gameVocabularyListController.sink.add(_listGameVocabulary!);
    }
  }

  void previousQuestion() async {
    _index = _index - 1;
    if (_index < 0) {
      _index = 0;
    }
    _initQuestionInfo();
  }

  void nextQuestion() async {
    _index = _index + 1;
    if (_index < (_listGameVocabulary?.length ?? 0)) {
      _initQuestionInfo();
    } else {
      await getData();
    }
  }

  Future<void> dispose() => _gameVocabularyListController.close();

  GameType randomGameType({int count = 2}) {
    final random = Random();

    final randomIndex = random.nextInt(count);

    return GameType.values[randomIndex];
  }

  bool lastQuestion() {
    return _index == (_listGameVocabulary?.length ?? 0 - 1);
  }

  bool firstQuestion() {
    return _index == 0;
  }

  void answer(bool isAnswerRight, {int? index, String? input}) {
    var answer = GameAnswerStatus(isAnswer: true, index: index, input: input);
    _listGameAnswerStatus?[_index] = answer;
    _gameAnswerStatus.value = answer;
  }

  void _initQuestionInfo() {
    _vocabulary.value = _listGameVocabulary?[_index];
    var answer = _listGameAnswerStatus?.elementAtOrNull(_index);
    if (answer == null) {
      answer = GameAnswerStatus();
      _listGameAnswerStatus?.add(answer);
    }
    _gameAnswerStatus.value = answer;
  }
}
