import 'dart:math';

import 'package:english_study/model/game_answer_status.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:english_study/screen/game/widget/widget_after_game.dart';
import 'package:english_study/screen/game/widget/widget_answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class ChooseAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  final GameType? gameType;
  ChooseAnswerComponent(
      {super.key, required this.gameVocabularyModel, this.gameType});

  bool isDefinition = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    var viewModel =
        Provider.of<GameVocabularyViewModel>(context, listen: false);
    return ValueListenableBuilder(
      valueListenable: viewModel.gameAnswerStatus,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Center(
                child: questionWidget(context, viewModel),
              ),
            )),
            answerWidget(value, 0, viewModel),
            answerWidget(value, 1, viewModel),
            answerWidget(value, 2, viewModel),
            answerWidget(value, 3, viewModel),
            const SizedBox(
              height: 10,
            ),
            AnimatedOpacity(
              duration: const Duration(
                milliseconds: duration_animation_next,
              ),
              opacity: value.isAnswer == true ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: duration_animation_next,
                ),
                width: double.infinity,
                height: value.isAnswer == true ? 55 : 0,
                child: WidgetAfterGame(
                  vocabulary: gameVocabularyModel?.main,
                  onNext: () {
                    viewModel.nextQuestion();
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        );
      },
    );
  }

  Widget questionWidget(
      BuildContext context, GameVocabularyViewModel viewModel) {
    switch (gameType) {
      case GameType.ChooseAnswerAudioToDefination:
        return InkWell(
            onTap: () {
              viewModel.playAudio(gameVocabularyModel?.main.audios?[0]);
            },
            child: widgetIcon('assets/icons/ic_audio.svg', size: 40));
      case GameType.ChooseAnswerSpellingToDefination:
      case GameType.ChooseAnswerSpellingToWord:
        return Text(
          (gameVocabularyModel?.main.spellings?[0].text ?? ''),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontFamily: "Noto", fontSize: 20),
        );

      default:
        return Text(
          question(gameType),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        );
    }
  }

  Widget answerWidget(
      GameAnswerStatus value, int index, GameVocabularyViewModel viewModel) {
    var vocabulary = gameVocabularyModel?.vocabularies[index];
    bool isAnswerRight = gameVocabularyModel?.main.id == vocabulary?.id;
    return WidgetAnswer(
      typeAnswer: getTypeAnswer(value, isAnswerRight, index),
      answer: answer(gameType, vocabulary),
      isSpelling: gameType == GameType.ChooseAnswerSpellingToDefination ||
          gameType == GameType.ChooseAnswerSpellingToWord,
      onSelect: () {
        if (value.isAnswer == true) return;
        viewModel.answer(isAnswerRight, index: index);
      },
    );
  }

  int getTypeAnswer(GameAnswerStatus value, bool isAnswerRight, int index) {
    return value.isAnswer == false
        ? 1
        : value.index == index
            ? isAnswerRight == true
                ? 2
                : 3
            : isAnswerRight == true
                ? 2
                : 1;
  }

  String answer(
    GameType? gameType,
    Vocabulary? vocabulary,
  ) {
    switch (gameType) {
      case GameType.ChooseAnswerAudioToDefination:
        return vocabulary?.description ?? '';
      case GameType.ChooseAnswerDefinationToWord:
        return vocabulary?.word ?? '';
      // case GameType.ChooseAnswerExampleToWord:
      //   return vocabulary?.word ?? '';
      case GameType.ChooseAnswerSpellingToWord:
        return vocabulary?.word ?? '';
      case GameType.ChooseAnswerSpellingToDefination:
        return vocabulary?.description ?? '';
      default:
        return '';
    }
  }

  String question(GameType? gameType) {
    switch (gameType) {
      case GameType.ChooseAnswerDefinationToWord:
        return gameVocabularyModel?.main.description ?? '';
      // case GameType.ChooseAnswerExampleToWord:
      //   return gameVocabularyModel?.main.examples?.first.sentence
      //           ?.replaceAllMapped(
      //               RegExp(
      //                   r'\b' + (gameVocabularyModel?.main.word ?? '') + '\w*'),
      //               (match) {
      //         return '_____';
      //       }) ??
      //       '';
      default:
        return '';
    }
  }
}
