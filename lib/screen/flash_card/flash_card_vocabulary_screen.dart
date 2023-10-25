import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/flash_card/component/example_component.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'component/vocabulary_component.dart';

class FlashCardScreen extends StatelessWidget {
  static String routeName = '/flash_card';
  const FlashCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var db = getIt<DBProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: db.getVocabulary(
              ModalRoute.of(context)?.settings.arguments as String?),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return buildCaroselCard(context, snapshot.data);
            }
          },
        ),
      ),
    );
  }

  Widget buildCaroselCard(BuildContext context, List<Vocabulary>? data) {
    return CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          viewportFraction: 0.9,
          onPageChanged: (index, reason) {
            var db = getIt<DBProvider>();
            data?[index].isLearn = 1;
            db.updateVocabulary(data?[index]);
          },
        ),
        items: data?.map((item) {
          FlipCardController _controller = FlipCardController();
          return FlipCard(
            controller: _controller,
            fill: Fill.fillBack,
            side: CardSide.FRONT,
            flipOnTouch: false,
            front: VocabularyComponent(
              vocabulary: item,
              onOpenExample: () {
                _controller.toggleCard();
              },
              isGame: false,
            ),
            back: ExampleComponent(
                vocabulary: item,
                onOpenVocabulary: () {
                  _controller.toggleCard();
                },
                isGame: false),
          );
        }).toList());
  }
}
