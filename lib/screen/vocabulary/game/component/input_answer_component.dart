import 'package:english_study/constants.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/screen/vocabulary/game/game_vocabulary_view_model.dart';
import 'package:english_study/screen/vocabulary/game/widget/widget_after_game.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                        child: questionWidget(context, viewModel),
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
                                    color: viewModel.isAnswerRight(
                                            gameVocabularyModel,
                                            inputController.text)
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
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

  Widget questionWidget(
      BuildContext context, GameVocabularyViewModel viewModel) {
    switch (gameType) {
      case GameType.InputAudioToWord:
        return GestureDetector(
            onTap: () {
              viewModel.playAudio(gameVocabularyModel?.main.audios?.getOrNull(0));
            },
            child: widgetIcon('assets/icons/ic_audio.svg', size: 40));
      case GameType.InputSpellingToDefination:
      case GameType.InputSpellingToWord:
        return Text((gameVocabularyModel?.main.spellings?.getOrNull(0)?.text ?? ''),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontFamily: "Noto", fontSize: 20));

      default:
        return Text(
          question(gameType),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20),
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
      // case GameType.InputExampleToWord:
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
