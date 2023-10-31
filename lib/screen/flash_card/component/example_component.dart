import 'package:english_study/constants.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:flutter/material.dart';

class ExampleComponent extends StatelessWidget {
  final Vocabulary? vocabulary;
  final Function onOpenVocabulary;
  final bool isGame;
  const ExampleComponent(
      {super.key,
      required this.vocabulary,
      required this.onOpenVocabulary,
      this.isGame = true});

  @override
  Widget build(BuildContext context) {
    List<Example>? examples = vocabulary?.examples;
    return Card(
      elevation: isGame ? 0 : 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isGame ? 0 : 15.0),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: isGame ? 65 : 10, left: 10, right: 10, bottom: 55),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(
                          examples?[index].sentence ?? '',
                          style: TextStyle(
                            color: maastricht_blue,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                    itemCount: examples?.length ?? 0,
                  ),
                )
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  onOpenVocabulary.call();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: turquoise,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(isGame ? 0 : 15),
                      bottomRight: Radius.circular(isGame ? 0 : 15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'View Vocabulary',
                    style: TextStyle(
                      color: maastricht_blue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
