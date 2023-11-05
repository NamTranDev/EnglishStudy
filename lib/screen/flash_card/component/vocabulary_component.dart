import 'package:english_study/constants.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/flash_card/widget/widget_audio_spelling.dart';
import 'package:flutter/material.dart';

class VocabularyComponent extends StatelessWidget {
  final Vocabulary? vocabulary;
  final Function onOpenExample;
  final bool isGame;
  const VocabularyComponent(
      {super.key,
      required this.vocabulary,
      required this.onOpenExample,
      this.isGame = true});

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
                top: isGame ? 55 : 10, left: 10, right: 10, bottom: 55),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: widgetImage(vocabulary?.image),
                  ),
                  flex: 3,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(vocabulary?.word ?? '',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: maastricht_blue,
                              width: 0.5,
                            )),
                            padding: EdgeInsets.all(5),
                            child: Text(vocabulary?.word_type ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (vocabulary?.audios != null && vocabulary?.spellings != null)
                  Expanded(
                    flex: 2,
                    child: WidgetAudioSpellig(
                        audios: vocabulary?.audios,
                        spellings: vocabulary?.spellings),
                  ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Text(
                        vocabulary?.description ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
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
                child: InkWell(
                  onTap: () {
                    onOpenExample.call();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: maastricht_blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(isGame ? 0 : 15),
                        bottomRight: Radius.circular(isGame ? 0 : 15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('View Examples',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white)),
                  ),
                ))
        ],
      ),
    );
  }
}
