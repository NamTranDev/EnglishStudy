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
                          decoration: InputDecoration(),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        
                      },
                      child: Center(
                        child: Text('Kiểm tra'),
                      ),
                    ),
                  ),
                )
              ],
            ),
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
            )
          ],
        );
      },
    );
  }
}
