import 'package:english_study/model/vocabulary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class VocabularyComponent extends StatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyComponent({super.key, required this.vocabulary});

  @override
  State<VocabularyComponent> createState() => _VocabularyComponentState();
}

class _VocabularyComponentState extends State<VocabularyComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
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
              itemCount: widget.vocabulary.spellings?.length ?? 0,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(widget.vocabulary.spellings?[index].text ?? ''),
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
              itemCount: widget.vocabulary.audios?.length ?? 0,
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
          Text(widget.vocabulary.description ?? '')
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
