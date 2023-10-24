import 'package:english_study/constants.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VocabularyComponent extends StatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyComponent({super.key, required this.vocabulary});

  @override
  State<VocabularyComponent> createState() => _VocabularyComponentState();
}

class _VocabularyComponentState extends State<VocabularyComponent> {
  double angle = 0;

  bool isBack = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          angle = (angle + pi) % (2 * pi);
        });
      },
      child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: angle),
          duration: Duration(seconds: 1),
          builder: (BuildContext context, double val, __) {
            //here we will change the isBack val so we can change the content of the card
            if (val >= (pi / 2)) {
              isBack = false;
            } else {
              isBack = true;
            }
            return (Transform(
              //let's make the card flip by it's center
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(val),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: isBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(
                                pi), // it will flip horizontally the container
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                widgetImage(null),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(widget.vocabulary.word ?? '',
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
                                    itemCount:
                                        widget.vocabulary.spellings?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Text(
                                          widget.vocabulary.spellings?[index]
                                                  .text ??
                                              '',
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
                                    itemCount:
                                        widget.vocabulary.audios?.length ?? 0,
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
                                Text(widget.vocabulary.description ?? ''),
                                SizedBox(
                                  height: 20,
                                ),
                                if (widget.vocabulary.examples?.isNotEmpty ==
                                    true)
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 100,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: maastricht_blue,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'View Examples',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.amber,
                        ) //if it's back we will display here
                  //else we will display it here,
                  ),
            ));
          }),
    );
  }

  Widget widgetImage(String? image) {
    return image != null
        ? Image.asset('assets/image/' + image)
        : Image.asset('assets/no_image.jpg');
  }
}
