import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/game_vocabulary_model.dart';

class InputAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  TextEditingController inputController = TextEditingController();
  InputAnswerComponent({super.key, required this.gameVocabularyModel});

  @override
  Widget build(BuildContext context) {
    var _viewModel =
        Provider.of<GameVocabularyViewModel>(context, listen: false);
    return ValueListenableBuilder(
      valueListenable: _viewModel.gameAnswerStatus,
      builder: (context, value, child) {
        inputController.text = value.input ?? '';
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Center(
                        child: Text(
                          gameVocabularyModel?.main.description ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                Expanded(
                    flex: 4,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: TextField(
                          controller: inputController,
                          enabled: !value.isAnswer,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: inputController.text ==
                                            gameVocabularyModel?.main.word
                                        ? Colors.green
                                        : Colors.red)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        _viewModel.answer(
                            inputController.text ==
                                gameVocabularyModel?.main.word,
                            input: inputController.text);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(border: Border.all(
                          color: Colors.grey.shade100
                        )),
                        width: double.infinity,
                        child: Center(
                          child: Text('Kiểm tra',style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ),
                  ),
                )
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
          ],
        );
      },
    );
  }
}
