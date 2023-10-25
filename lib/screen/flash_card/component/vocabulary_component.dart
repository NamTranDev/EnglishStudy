import 'package:english_study/constants.dart';
import 'package:english_study/model/vocabulary.dart';
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
                top: isGame ? 55 : 10,
                left: 10,
                right: 10,
                bottom: isGame ? 10 : 55),
            child: Column(
              children: [
                widgetImage(null),
                SizedBox(
                  height: 10,
                ),
                Text(vocabulary?.word ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 50,
                    ),
                    textAlign: TextAlign.center),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: vocabulary?.spellings?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          vocabulary?.spellings?[index].text ?? '',
                          style: TextStyle(fontFamily: 'Noto'),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: vocabulary?.audios?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Icon(
                          Icons.audio_file,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(vocabulary?.description ?? ''),
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
                    decoration: BoxDecoration(
                      color: maastricht_blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(isGame ? 0 : 15),
                        bottomRight: Radius.circular(isGame ? 0 : 15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View Examples',
                      style: TextStyle(
                        color: turquoise,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ))
        ],
      ),
    );
  }

  Widget widgetImage(String? image) {
    return image != null
        ? Image.asset('assets/image/' + image)
        : Image.asset('assets/no_image.jpg');
  }
}
