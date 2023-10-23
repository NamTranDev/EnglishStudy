import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/model/game_type.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/screen/game/component/choose_answer_component.dart';
import 'package:english_study/screen/game/component/input_answer_component.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../storage/db_provider.dart';

class GameVocabularyScreen extends StatefulWidget {
  static String routeName = '/vocabulary_name';
  const GameVocabularyScreen({super.key});

  @override
  State<GameVocabularyScreen> createState() => _GameVocabularyScreenState();
}

class _GameVocabularyScreenState extends State<GameVocabularyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Provider.value(
        value: GameVocabularyViewModel(
            ModalRoute.of(context)?.settings.arguments as String?),
        child: Consumer<GameVocabularyViewModel>(
          builder: (context, value, child) {
            return SafeArea(
              child: StreamBuilder(
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
                          case GameType.InputExampleToWord:
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
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
