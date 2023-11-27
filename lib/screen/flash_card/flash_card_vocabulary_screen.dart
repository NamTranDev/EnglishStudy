import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/reuse/component/game_button_component.dart';
import 'package:english_study/screen/flash_card/component/button_falling.dart';
import 'package:english_study/screen/flash_card/component/example_component.dart';
import 'package:english_study/screen/flash_card/flash_card_view_model.dart';
import 'package:english_study/screen/game/game_vocabulary_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

import 'component/vocabulary_component.dart';

class FlashCardScreen extends StatefulWidget {
  static String routeName = '/flash_card';

  const FlashCardScreen({super.key});

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  final tooltipController = JustTheController();
  late FlashCardViewModel _viewModel;

  @override
  void dispose() {
    _viewModel.disposeAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: FlashCardViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BackScreenComponent(
            icon_asset: 'assets/icons/ic_close.svg',
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return buildCaroselCard(context, snapshot.data);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCaroselCard(BuildContext context, List<Vocabulary>? data) {
    _viewModel = Provider.of<FlashCardViewModel>(context);
    return Stack(
      children: [
        Positioned.fill(
          child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.925,
                enlargeFactor: 0.2,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                // enlargeFactor: 0.5,
                initialPage: _viewModel.index,
                onPageChanged: (index, reason) {
                  _viewModel
                      .updateIndexVocabulary('${index + 1}/${data?.length}');
                  _viewModel.playAudio(data?[index].audios?[0]);
                  _viewModel.updateVocabulary(data?[index]);
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
                      _viewModel.playAudio(audio);
                    },
                  ),
                  back: ExampleComponent(
                      vocabulary: item,
                      onOpenVocabulary: () {
                        _controller.toggleCard();
                      },
                      isGame: false),
                );
              }).toList()),
        ),
        Positioned(
          top: 5,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: maastricht_blue,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: ValueListenableBuilder(
                      valueListenable: _viewModel.indexVocabulary,
                      builder: (context, value, child) {
                        return Text(
                          value ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _viewModel.canPlayGame,
                      builder: (context, value, child) {
                        return value
                            ? JustTheTooltip(
                                backgroundColor: maastricht_blue,
                                controller: tooltipController,
                                tailLength: 6,
                                tailBaseWidth: 10.0,
                                isModal: true,
                                preferredDirection: AxisDirection.down,
                                borderRadius: BorderRadius.circular(8.0),
                                offset: 5,
                                content: Container(
                                  width: 150,
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'You can play games to learn vocabulary more effectively',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                child: ButtonFalling(
                                  child: GameButtonComponent(
                                    onClick: () {
                                      Navigator.pushNamed(context,
                                          GameVocabularyScreen.routeName,
                                          arguments: (ModalRoute.of(context)
                                                  ?.settings
                                                  .arguments as String?)
                                              ?.toString());
                                    },
                                  ),
                                  onAnimationComplete: () async {
                                    if (_viewModel.isShowGuideLearnWithGame()) {
                                      tooltipController.showTooltip();
                                    }
                                  },
                                ),
                              )
                            : SizedBox();
                      })
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
