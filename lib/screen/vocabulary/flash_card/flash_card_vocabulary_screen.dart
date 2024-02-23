import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/reuse/component/game_button_component.dart';
import 'package:english_study/screen/vocabulary/flash_card/component/button_falling.dart';
import 'package:english_study/screen/vocabulary/flash_card/component/example_component.dart';
import 'package:english_study/screen/vocabulary/flash_card/flash_card_view_model.dart';
import 'package:english_study/screen/vocabulary/game/game_vocabulary_screen.dart';
import 'package:english_study/utils/extension.dart';
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
                _viewModel = value;
                return FutureBuilder(
                  future: value.vocabularies(
                      ModalRoute.of(context)?.settings.arguments as SubTopic?),
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
                      return buildCaroselCard(snapshot.data);
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

  Widget buildCaroselCard(List<Vocabulary>? data) {
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
                  _viewModel.syncVocabulary(data?.getOrNull(index),
                      lastItem: (data?.length ?? 0) - 1 == index);
                  _viewModel
                      .playAudio(data?.getOrNull(index)?.audios?.getOrNull(0));
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
                    onUpdateNote: (vocabulary) {
                      _viewModel.updateVocabulary(vocabulary);
                    },
                    isFirst: data.indexOf(item) == 0,
                  ),
                  back: ExampleComponent(
                      vocabulary: item,
                      onOpenVocabulary: () {
                        _controller.toggleCard();
                      },
                      onUpdateNote: (example) {
                        _viewModel.updateExample(example);
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
                                    onClick: () async {
                                      _viewModel.nextScreen = true;
                                      await Navigator.pushNamed(context,
                                          GameVocabularyScreen.routeName,
                                          arguments: (ModalRoute.of(context)
                                                  ?.settings
                                                  .arguments as String?)
                                              ?.toString());
                                      if (!_viewModel.nextScreen) {
                                        var isShowTooltipGuideGame = _viewModel
                                            .isShowGuideLearnWithGame();
                                        print(isShowTooltipGuideGame);
                                        if (isShowTooltipGuideGame) {
                                          tooltipController.showTooltip();
                                        }
                                      }
                                    },
                                  ),
                                  onAnimationComplete: () async {
                                    var isShowTooltipGuideGame =
                                        _viewModel.isShowGuideLearnWithGame();
                                    print(isShowTooltipGuideGame);
                                    if (isShowTooltipGuideGame) {
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
