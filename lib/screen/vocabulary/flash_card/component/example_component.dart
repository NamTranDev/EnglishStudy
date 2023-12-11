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
                top: isGame ? 100 : 50, left: 10, right: 10, bottom: 100),
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
                          style: Theme.of(context).textTheme.bodySmall,
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
                  margin: EdgeInsets.only(
                      left: isGame ? 5 : 0,
                      right: isGame ? 5 : 0,
                      bottom: isGame ? 40 : 0),
                  decoration: BoxDecoration(
                    color: turquoise,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isGame ? 5 : 0),
                      topRight: Radius.circular(isGame ? 5 : 0),
                      bottomLeft: Radius.circular(isGame ? 5 : 15),
                      bottomRight: Radius.circular(isGame ? 5 : 15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'View Vocabulary',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
