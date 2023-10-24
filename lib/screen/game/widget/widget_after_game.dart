import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WidgetAfterGame extends StatelessWidget {
  final Function? onNext;
  final Function? onReviewVocabulary;

  const WidgetAfterGame(
      {super.key, required this.onNext, required this.onReviewVocabulary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            onReviewVocabulary?.call();
          },
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_vocabulary.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Review',
                style: TextStyle(fontSize: 15, color: maastricht_blue),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () {
            onNext?.call();
          },
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_arrow_next.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Next',
                style: TextStyle(fontSize: 15, color: maastricht_blue),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 40,
        )
      ],
    );
  }
}
