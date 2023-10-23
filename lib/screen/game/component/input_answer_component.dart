import 'package:english_study/model/game_type.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/game_vocabulary_model.dart';

class InputAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  final GameType? gameType;
  TextEditingController inputController = TextEditingController();
  InputAnswerComponent(
      {super.key, required this.gameVocabularyModel, this.gameType});

  @override
  Widget build(BuildContext context) {
    var viewModel =
        Provider.of<GameVocabularyViewModel>(context, listen: false);
    return ValueListenableBuilder(
      valueListenable: viewModel.gameAnswerStatus,
      builder: (context, value, child) {
        inputController.text = value.input ?? '';
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      child: Center(
                        child: gameType == GameType.InputAudioToWord
                            ? IconButton(
                                onPressed: () {}, icon: Icon(Icons.audio_file))
                            : Text(
                                question(gameType),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
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
                            border: const OutlineInputBorder(
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
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        viewModel.answer(
                            inputController.text ==
                                gameVocabularyModel?.main.word,
                            input: inputController.text);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100)),
                        width: double.infinity,
                        height: 50,
                        child: Center(
                          child: Text(
                            'Kiểm tra',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: 20,
              left: 20,
              child: AnimatedOpacity(
                duration: Duration(
                  milliseconds: value.isAnswer == true ? 500 : 0,
                ),
                opacity: value.isAnswer == true ? 1.0 : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  transform: Matrix4.diagonal3Values(
                      value.isAnswer ? 1 : 10, value.isAnswer ? 1 : 10, 1.0),
                  child: Transform.rotate(
                    angle: 75,
                    child: Image(
                      image: AssetImage(
                          inputController.text == gameVocabularyModel?.main.word
                              ? "assets/background/background_right.webp"
                              : "assets/background/background_wrong.webp"),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(
                  milliseconds: 500,
                ),
                opacity: value.isAnswer == true ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        viewModel.nextQuestion();
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.navigate_next),
                          Text('Next'),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String question(GameType? gameType) {
    switch (gameType) {
      case GameType.InputDefinationToWord:
        return gameVocabularyModel?.main.description ?? '';
      case GameType.InputExampleToWord:
        return gameVocabularyModel?.main.examples?.first.sentence
                ?.replaceAll(gameVocabularyModel?.main.word ?? '', ' _____ ') ??
            '';
      case GameType.InputSpellingToDefination:
      case GameType.InputSpellingToWord:
        return gameVocabularyModel?.main.spellings
                ?.map((e) => e.text)
                .join(" - ") ??
            '';
    }
    return '';
  }
}
