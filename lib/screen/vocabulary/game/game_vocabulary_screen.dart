import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/vocabulary/game/component/choose_answer_component.dart';
import 'package:english_study/screen/vocabulary/game/component/input_answer_component.dart';
import 'package:english_study/screen/vocabulary/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class GameVocabularyScreen extends StatelessWidget {
  static String routeName = '/vocabulary_name';
  const GameVocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Provider.value(
          value: GameVocabularyViewModel(
              ModalRoute.of(context)?.settings.arguments as String?),
          child: BackScreenComponent(
            child: Consumer<GameVocabularyViewModel>(
              builder: (context, value, child) {
                return StreamBuilder(
                  stream: value.gameVocabularyList,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "Something wrong with message: ${snapshot.error.toString()}"),
                      );
                    } else if (snapshot.hasData &&
                        snapshot.data?.isNotEmpty == true) {
                      return ValueListenableBuilder(
                        valueListenable: value.vocabulary,
                        builder: (context, value, child) {
                          GameType? type = value?.type;
                          type ??= Provider.of<GameVocabularyViewModel>(context)
                              .randomGameType();

                          switch (type) {
                            case GameType.InputAudioToWord:
                            case GameType.InputDefinationToWord:
                            // case GameType.InputExampleToWord:
                            case GameType.InputSpellingToWord:
                            case GameType.InputSpellingToDefination:
                              return InputAnswerComponent(
                                gameVocabularyModel: value,
                                gameType: type,
                              );

                            default:
                              return ChooseAnswerComponent(
                                gameVocabularyModel: value,
                                gameType: type,
                              );
                          }
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
