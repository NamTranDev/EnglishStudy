import 'dart:math';

import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RightOrWrongAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  RightOrWrongAnswerComponent({super.key, this.gameVocabularyModel});

  bool isDefinition = Random().nextBool();

  @override
  Widget build(BuildContext context) {
    var _viewModel =
        Provider.of<GameVocabularyViewModel>(context, listen: false);
    return ValueListenableBuilder(
        valueListenable: _viewModel.gameAnswerStatus,
        builder: (context, value, child) {
          return Stack(children: [
            Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    child: Center(
                      child: Text(
                        isDefinition
                            ? gameVocabularyModel?.main.description ?? ''
                            : gameVocabularyModel?.main.word ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      
                    ],
                  ))
              ],
            ),
            if (!_viewModel.lastQuestion())
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: value.isAnswer == true
                    ? Expanded(
                        child: Container(
                        width: 100,
                        height: 100,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _viewModel.nextQuestion();
                            },
                            child: Icon(Icons.navigate_next),
                          ),
                        ),
                      ))
                    : SizedBox(),
              ),
            if (!_viewModel.firstQuestion())
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Expanded(
                    child: Container(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _viewModel.previousQuestion();
                      },
                      child: Icon(Icons.navigate_before),
                    ),
                  ),
                )),
              ),
          ]);
        });
  }
}
