import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/screen/flash_card/component/example_component.dart';
import 'package:english_study/screen/flash_card/flash_card_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'component/vocabulary_component.dart';

class FlashCardScreen extends StatelessWidget {
  static String routeName = '/flash_card';
  const FlashCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: FlashCardViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<FlashCardViewModel>(
            builder: (context, value, child) {
              return FutureBuilder(
                future: value.vocabularies(
                    ModalRoute.of(context)?.settings.arguments as String?),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Something wrong with message: ${snapshot.error.toString()}"),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                        child: buildCaroselCard(context, snapshot.data));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildCaroselCard(BuildContext context, List<Vocabulary>? data) {
    var viewModel = Provider.of<FlashCardViewModel>(context);
    return CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height - 50,
          viewportFraction: 0.925,
          enlargeFactor: 0.2,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          // enlargeFactor: 0.5,
          onPageChanged: (index, reason) {
            viewModel.playAudio(data?[index].audios?[0]);
            viewModel.updateVocabulary(data?[index]);
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
              onPlayAudio: (audio) {
                viewModel.playAudio(audio);
              },
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
