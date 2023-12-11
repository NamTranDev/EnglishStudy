import 'package:english_study/constants.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/spelling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WidgetAudioSpellig extends StatelessWidget {
  final List<Audio>? audios;
  final List<Spelling>? spellings;
  final Function(Audio?) onPlayAudio;

  const WidgetAudioSpellig(
      {super.key,
      required this.audios,
      required this.spellings,
      required this.onPlayAudio});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: audios?.length == 2 && spellings?.length == 2
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  audioSpellingWithFlag(audios?[0], spellings?[0], true),
                  SizedBox(
                    width: 30,
                  ),
                  audioSpellingWithFlag(audios?[1], spellings?[1], false),
                ],
              ),
            )
          : Column(
              children: [
                widgetAudio(audios?[0]),
                SizedBox(
                  height: 10,
                ),
                widgetSpelling(spellings?[0])
              ],
            ),
    );
  }

  Widget audioSpellingWithFlag(Audio? audio, Spelling? spelling, bool isUK) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widgetAudio(audio),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            widgetIcon(isUK
                ? 'assets/icons/ic_flag_uk.svg'
                : 'assets/icons/ic_flag_us.svg'),
            SizedBox(
              width: 5,
            ),
            widgetSpelling(spelling)
          ],
        ),
      ],
    );
  }

  Widget widgetAudio(Audio? audio) {
    return GestureDetector(
      onTap: () {
        onPlayAudio.call(audio);
      },
      child: widgetIcon('assets/icons/ic_audio.svg'),
    );
  }

  Widget widgetSpelling(Spelling? spelling) {
    return Text(
      spellings?[0].text ?? '',
      style: const TextStyle(
          fontFamily: 'Noto',
          fontSize: 15,
          color: maastricht_blue,
          fontWeight: FontWeight.normal),
    );
  }
}
