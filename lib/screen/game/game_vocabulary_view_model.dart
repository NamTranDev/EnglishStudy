import 'dart:async';
import 'dart:math';

import 'package:english_study/model/game_answer_status.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';

class GameVocabularyViewModel {
  final String? subTopicId;

  final ValueNotifier<GameVocabularyModel?> _vocabulary =
      ValueNotifier<GameVocabularyModel?>(null);
  ValueNotifier<GameVocabularyModel?> get vocabulary => _vocabulary;

  final ValueNotifier<GameAnswerStatus> _gameAnswerStatus =
      ValueNotifier<GameAnswerStatus>(GameAnswerStatus());
  ValueNotifier<GameAnswerStatus> get gameAnswerStatus => _gameAnswerStatus;

  List<GameVocabularyModel>? _gameVocabularies;
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
    _gameVocabularies = subTopicId == null
        ? await db.vocabularyGameLearn()
        : await db.vocabularyGameSubTopic(subTopicId!);
    // await Future.delayed(Duration(seconds: 2));
    // _gameVocabularies = _gameVocabularies?.sublist(0, 2);
    if (_gameVocabularies == null)
      _gameVocabularyListController.sink.addError("Not found list Vocabulary");
    else {
      _index = 0;
      _initQuestionInfo();
      _gameVocabularyListController.sink.add(_gameVocabularies!);
    }
  }

  void nextQuestion() async {
    _index = _index + 1;
    _gameAnswerStatus.value = GameAnswerStatus();
    if (_index < (_gameVocabularies?.length ?? 0)) {
      _initQuestionInfo();
    } else {
      await getData();
    }
  }

  Future<void> dispose() => _gameVocabularyListController.close();

  GameType randomGameType() {
    final random = Random();

    final randomIndex = random.nextInt(2);

    try {
      return GameType.values[randomIndex];
    } catch (_) {
      return GameType.ChooseAnswer;
    }
  }

  void answer(int index, bool isAnswerRight) {
    _gameAnswerStatus.value = GameAnswerStatus(
      isAnswer: true,
      index: index,
    );
  }

  void _initQuestionInfo() {
    _vocabulary.value = _gameVocabularies?[_index];
  }
}
