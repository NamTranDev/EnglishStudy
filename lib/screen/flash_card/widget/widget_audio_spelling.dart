import 'package:english_study/constants.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/spelling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WidgetAudioSpellig extends StatelessWidget {
  final List<Audio>? audios;
  final List<Spelling>? spellings;

  const WidgetAudioSpellig(
      {super.key, required this.audios, required this.spellings});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: audios?.length == 2 && spellings?.length == 2
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                audioSpellingWithFlag(audios?[0], spellings?[0], true),
                SizedBox(
                  width: 30,
                ),
                audioSpellingWithFlag(audios?[1], spellings?[1], false),
              ],
            )
          : Center(
              child: Column(
                children: [
                  widgetAudio(audios?[0]),
                  widgetSpelling(spellings?[0])
                ],
              ),
            ),
    );
  }

  Widget audioSpellingWithFlag(Audio? audio, Spelling? spelling, bool isUK) {
    return Column(
      children: [
        widgetAudio(audio),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SvgPicture.asset(
              isUK
                  ? 'assets/icons/ic_flag_uk.svg'
                  : 'assets/icons/ic_flag_us.svg',
              width: 30,
              height: 30,
            ),
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
    return InkWell(
      onTap: () {},
      child: SvgPicture.asset(
        'assets/icons/ic_audio.svg',
        width: 30,
        height: 30,
      ),
    );
  }

  Widget widgetSpelling(Spelling? spelling) {
    return Text(
      spellings?[0].text ?? '',
      style:
          TextStyle(fontFamily: 'Noto', fontSize: 15, color: maastricht_blue),
    );
  }
}
