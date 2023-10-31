import 'package:english_study/model/game_type.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:english_study/screen/game/widget/widget_after_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../model/game_vocabulary_model.dart';

class InputAnswerComponent extends StatelessWidget {
  final GameVocabularyModel? gameVocabularyModel;
  final GameType? gameType;
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  InputAnswerComponent(
      {super.key, required this.gameVocabularyModel, this.gameType});

  @override
  Widget build(BuildContext context) {
    var viewModel =
        Provider.of<GameVocabularyViewModel>(context, listen: false);
    inputFocus.requestFocus();
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Center(
                        child: questionWidget(),
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
                          focusNode: inputFocus,
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
                          onSubmitted: (value) {
                            checkAnswer(viewModel);
                          },
                        ),
                      ),
                    )),
                Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                            color: maastricht_blue,
                            borderRadius: BorderRadius.circular(5)),
                        child: InkWell(
                          onTap: () {
                            checkAnswer(viewModel);
                          },
                          child: Center(
                            child: Text(
                              'Kiểm tra',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
            Positioned(
              top: 20,
              left: 20,
              child: AnimatedOpacity(
                duration: Duration(
                  milliseconds: value.isAnswer == true
                      ? duration_animation_right_wrong
                      : 0,
                ),
                opacity: value.isAnswer == true ? 1.0 : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: duration_animation_right_wrong,
                  ),
                  transform: Matrix4.diagonal3Values(value.isAnswer ? 1 : 2,
                      value.isAnswer ? 1 : 2, value.isAnswer ? 1 : 1),
                  child: Transform.rotate(
                    angle: 75.15,
                    child: Image(
                      image: AssetImage(viewModel.isAnswerRight(
                              gameVocabularyModel, inputController.text)
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
                  milliseconds: duration_animation_next,
                ),
                opacity: value.isAnswer == true ? 1.0 : 0.0,
                child: WidgetAfterGame(
                  vocabulary: gameVocabularyModel?.main,
                  onNext: () {
                    viewModel.nextQuestion();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget questionWidget() {
    switch (gameType) {
      case GameType.InputAudioToWord:
        return SvgPicture.asset(
          'assets/icons/ic_audio.svg',
          width: 40,
          height: 40,
        );
      case GameType.InputSpellingToDefination:
      case GameType.InputSpellingToWord:
        return Text(
          (gameVocabularyModel?.main.spellings?[0].text ?? ''),
          style: TextStyle(
            fontFamily: "Noto",
            color: maastricht_blue,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        );

      default:
        return Text(
          question(gameType),
          style: TextStyle(
            color: maastricht_blue,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  void checkAnswer(GameVocabularyViewModel viewModel) {
    if (inputController.text.isEmpty) {
      inputFocus.requestFocus();
      return;
    }
    // inputFocus.unfocus();
    viewModel.answer(
        viewModel.isAnswerRight(gameVocabularyModel, inputController.text),
        input: inputController.text);
  }

  String question(GameType? gameType) {
    switch (gameType) {
      case GameType.InputDefinationToWord:
        return gameVocabularyModel?.main.description ?? '';
      case GameType.InputExampleToWord:
        return gameVocabularyModel?.main.examples?.first.sentence
                ?.replaceAllMapped(
                    RegExp(
                        r'\b' + (gameVocabularyModel?.main.word ?? '') + '\w*'),
                    (match) {
              return '_____';
            }) ??
            '';
      default:
        return '';
    }
  }
}
