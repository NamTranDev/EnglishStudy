import 'dart:math';

import 'package:english_study/model/game_answer_status.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  ChooseAnswerComponent({super.key, required this.gameVocabularyModel});

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
                  )),
              Expanded(
                  flex: 5,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var vocabulary = gameVocabularyModel?.vocabularies[index];
                      bool isAnswerRight =
                          gameVocabularyModel?.main.id == vocabulary?.id;
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            if (value.isAnswer == true) return;
                            _viewModel.answer(isAnswerRight,index: index);
                          },
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              color: value.isAnswer == false
                                  ? Colors.white
                                  : (value.index == index
                                      ? (isAnswerRight
                                          ? Colors.green
                                          : Colors.red)
                                      : Colors.white),
                              child: Center(
                                child: Text(
                                  isDefinition
                                      ? vocabulary?.word ?? ''
                                      : vocabulary?.description ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: gameVocabularyModel?.vocabularies.length ?? 0,
                  )),
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
      },
    );
  }
}
