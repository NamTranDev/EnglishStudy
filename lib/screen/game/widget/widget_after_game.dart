import 'package:english_study/constants.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/flash_card/component/example_component.dart';
import 'package:english_study/screen/flash_card/component/vocabulary_component.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WidgetAfterGame extends StatelessWidget {
  final Vocabulary? vocabulary;
  final Function? onNext;

  const WidgetAfterGame(
      {super.key, required this.onNext, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                FlipCardController _controller = FlipCardController();
                return SafeArea(
                  child: Stack(
                    children: [
                      FlipCard(
                        controller: _controller,
                        fill: Fill.none,
                        side: CardSide.FRONT,
                        flipOnTouch: false,
                        front: VocabularyComponent(
                            vocabulary: vocabulary,
                            onOpenExample: () {
                              _controller.toggleCard();
                            }),
                        back: ExampleComponent(
                            vocabulary: vocabulary,
                            onOpenVocabulary: () {
                              _controller.toggleCard();
                            }),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/ic_arrow_down.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
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
