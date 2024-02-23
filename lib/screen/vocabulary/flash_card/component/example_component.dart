import 'package:english_study/constants.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/component/note_component.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class ExampleComponent extends StatelessWidget {
  final Vocabulary? vocabulary;
  final Function onOpenVocabulary;
  final Function onUpdateNote;
  final bool isGame;
  const ExampleComponent(
      {super.key,
      required this.vocabulary,
      required this.onOpenVocabulary,
      required this.onUpdateNote,
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
                top: isGame ? 100 : 50, left: 10, right: 10, bottom: 50),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var example = examples?.getOrNull(index);
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: example?.sentence ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              TextSpan(text: '  '),
                              if (example != null)
                                WidgetSpan(
                                  child: ListenableBuilder(
                                    listenable: example,
                                    builder: (context, widget) {
                                      return NoteComponent(
                                        text: vocabulary?.description,
                                        onNote: (note) {
                                          example.sentence_note =
                                              note.isEmpty ? null : note;
                                          example.notify();
                                          onUpdateNote.call(example);
                                        },
                                        note: example.sentence_note,
                                      );
                                    },
                                  ),
                                )
                            ],
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
                  margin: EdgeInsets.only(
                      left: isGame ? 5 : 0,
                      right: isGame ? 5 : 0,
                      bottom: isGame ? 40 : 0),
                  decoration: BoxDecoration(
                    color: sky_blue,
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
