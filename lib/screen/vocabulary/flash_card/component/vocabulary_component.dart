import 'package:english_study/constants.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/component/note_component.dart';
import 'package:english_study/screen/vocabulary/flash_card/widget/widget_audio_spelling.dart';
import 'package:flutter/material.dart';

class VocabularyComponent extends StatelessWidget {
  final Vocabulary? vocabulary;
  final Function onOpenExample;
  final bool isGame;
  final Function(Audio?) onPlayAudio;
  final Function(Vocabulary?) onUpdateNote;

  const VocabularyComponent({
    super.key,
    required this.vocabulary,
    required this.onOpenExample,
    this.isGame = true,
    required this.onPlayAudio,
    required this.onUpdateNote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isGame ? 0 : 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isGame ? 0 : 15.0),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: isGame ? 100 : 10, left: 10, right: 10, bottom: 100),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: widgetImage(vocabulary?.image_file_name,
                        vocabulary?.image_file_path,
                        fit: BoxFit.fill),
                  ),
                  flex: 3,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                //You can use FittedBox to manage text based on height or width.
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(vocabulary?.word ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 0,
                                child: vocabulary != null
                                    ? ListenableBuilder(
                                        listenable: vocabulary!,
                                        builder: (context, widget) {
                                          return NoteComponent(
                                            text: vocabulary?.word,
                                            onNote: (note) {
                                              vocabulary?.word_note = note;
                                              vocabulary?.update();
                                              onUpdateNote.call(vocabulary);
                                            },
                                            note: vocabulary?.word_note,
                                          );
                                        })
                                    : SizedBox(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(vocabulary?.word_type ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                if ((vocabulary?.audios?.length ?? 0) > 0 &&
                    (vocabulary?.spellings?.length ?? 0) > 0)
                  Expanded(
                    flex: 2,
                    child: WidgetAudioSpellig(
                      audios: vocabulary?.audios,
                      spellings: vocabulary?.spellings,
                      onPlayAudio: onPlayAudio,
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text: vocabulary?.description ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(text: '  '),
                          if (vocabulary != null)
                            WidgetSpan(
                              child: ListenableBuilder(
                                listenable: vocabulary!,
                                builder: (context, widget) {
                                  return NoteComponent(
                                    text: vocabulary?.description,
                                    onNote: (note) {
                                      vocabulary?.description_note = note;
                                      vocabulary?.update();
                                      onUpdateNote.call(vocabulary);
                                    },
                                    note: vocabulary?.description_note,
                                  );
                                },
                              ),
                            )
                        ]),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (vocabulary?.examples?.isNotEmpty == true)
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    onOpenExample.call();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.only(
                        left: isGame ? 5 : 0,
                        right: isGame ? 5 : 0,
                        bottom: isGame ? 40 : 0),
                    decoration: BoxDecoration(
                      color: maastricht_blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isGame ? 5 : 0),
                        topRight: Radius.circular(isGame ? 5 : 0),
                        bottomLeft: Radius.circular(isGame ? 5 : 15),
                        bottomRight: Radius.circular(isGame ? 5 : 15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('View Examples',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: sky_blue)),
                  ),
                ))
        ],
      ),
    );
  }
}
