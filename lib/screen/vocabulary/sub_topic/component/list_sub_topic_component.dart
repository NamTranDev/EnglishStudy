import 'package:english_study/constants.dart';
import 'package:english_study/localization/generated/l10n.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/check_complete_category.dart';
import 'package:english_study/reuse/component/banner_component.dart';
import 'package:english_study/reuse/component/download_banner_component.dart';
import 'package:english_study/reuse/component/game_button_component.dart';
import 'package:english_study/reuse/component/header_title_component.dart';
import 'package:english_study/reuse/component/next_category_component.dart';
import 'package:english_study/screen/vocabulary/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/vocabulary/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

class ListSubTopicComponent extends StatefulWidget {
  final Topic? topic;
  final bool fromTab;
  const ListSubTopicComponent({super.key, this.topic, required this.fromTab});

  @override
  State<ListSubTopicComponent> createState() => _ListSubTopicComponentState();
}

class _ListSubTopicComponentState extends State<ListSubTopicComponent> {
  late SubTopicViewModel _viewModel;
  late Localize _localize;
  final tooltipController = JustTheController();

  double marginLeft = 30;

  double sizeCircle = 120;

  int animationDuration = 2000;

  @override
  Widget build(BuildContext context) {
    _localize = getIt<Localize>();
    return Column(
      children: [
        Expanded(
          child: Consumer<SubTopicViewModel>(
            builder: (context, viewmodel, child) {
              _viewModel = viewmodel;
              _viewModel.downloadManager.onDownloadErrorListener = () {
                showSnackBar(
                    context, _localize.sub_topic_component_text_download_error,
                    iconSvg: 'assets/icons/ic_error.svg',
                    iconSvgColor: red_violet);
              };
              _viewModel.onShowGuideNextCategory = () {
                // tooltipController.showTooltip();
              };
              return FutureBuilder(
                future: viewmodel.initData(widget.topic, widget.fromTab),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Something wrong with message: ${snapshot.error.toString()}"),
                    );
                  } else if (snapshot.hasData) {
                    return Column(
                      children: [
                        HeaderTitleComponent(
                          title: widget.topic?.name,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _viewModel.showComplete,
                          builder: (context, value, child) {
                            return value
                                ? NextCategoryComponent(
                                    text: _localize
                                        .sub_topic_component_text_another_category,
                                    onNextCategoryClick: () {
                                      nextPickCategory(context, widget.topic);
                                    },
                                  )
                                : SizedBox();
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                              _viewModel.downloadManager.processItems,
                          builder: (context, value, child) {
                            FileInfo? fileInfo =
                                value?[widget.topic?.link_resource];
                            return fileInfo != null &&
                                    fileInfo.status != DownloadStatus.COMPLETE
                                ? Card(
                                    margin: EdgeInsets.only(left: 8, right: 8),
                                    elevation: 5,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: DownloadBannerComponent(
                                        text: _localize
                                            .sub_topic_component_text_download,
                                        process: fileInfo.progress,
                                        onDownloadClick: () {
                                          _viewModel.downloadManager.download(
                                              widget.topic?.link_resource);
                                        },
                                      ),
                                    ),
                                  )
                                : SizedBox();
                          },
                        ),
                        Expanded(
                            child: ListView.builder(
                          padding: EdgeInsets.only(top: 20),
                          itemBuilder: (context, index) {
                            // print(snapshot.data?.length);
                            // print(index);
                            // print(isLast);
                            return widgetSubTopicItem(snapshot.data, index);
                          },
                          itemCount: snapshot.data?.length ?? 0,
                        )),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            },
          ),
        ),
        if (widget.fromTab == false) const BannerComponent()
      ],
    );
  }

  Widget widgetSubTopicItem(List<SubTopic>? subTopics, int index) {
    SubTopic? subTopic = subTopics?.getOrNull(index);
    var isLast = index == ((subTopics?.length ?? 0) - 1);
    return ValueListenableBuilder(
      valueListenable: _viewModel.updateLessionStatus,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (subTopic?.isLearnComplete == 0 &&
                        subTopic?.isLearning == 0) {
                      showSnackBar(context,
                          _localize.sub_topic_component_text_warning_complete);
                      return;
                    }

                    var isHasResource = _viewModel.downloadManager
                        .checkHasResource(widget.topic?.link_resource);

                    var isDefault = index == 0 && widget.topic?.isDefault == 1;

                    if (!isHasResource && !isDefault) {
                      showSnackBar(
                          context,
                          _localize
                              .sub_topic_component_text_warning_need_download);
                      return;
                    }

                    var subTopicId = subTopic?.id.toString();

                    await Navigator.pushNamed(
                        context, FlashCardScreen.routeName,
                        arguments: subTopic);

                    if (subTopic?.isLearnComplete == 1) {
                      return;
                    }
                    if (await _viewModel.syncLession(subTopicId) == true) {
                      _viewModel.updateComplete(subTopics, index, widget.topic);
                    } else {
                      await _viewModel.syncProgress(subTopic);
                    }
                  },
                  child: Container(
                    width: sizeCircle,
                    height: sizeCircle,
                    margin: EdgeInsets.only(left: marginLeft),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 5,
                            color: subTopic?.isLearnComplete == 1 ||
                                    subTopic?.isLearning == 1
                                ? turquoise
                                : disable),
                        shape: BoxShape.circle,
                        color: subTopic?.image == null
                            ? maastricht_blue.withOpacity(0.8)
                            : Colors.transparent),
                    child: Stack(children: [
                      Positioned.fill(
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(sizeCircle), // Image radius
                            child: subTopic?.image == null
                                ? Center(
                                    child: Image.asset(
                                      'assets/background/topic_image.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  )
                                : widgetImage(
                                    subTopic?.image, subTopic?.image_path,
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      if (subTopic?.isLearnComplete == 0 &&
                          subTopic?.isLearning == 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.all(
                                Radius.circular(sizeCircle),
                              ),
                            ),
                            child: Center(
                              child: widgetIcon('assets/icons/ic_lock.svg',
                                  size: 30, color: Colors.white),
                            ),
                          ),
                        )
                    ]),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 50),
                        child: Text(
                          subTopic?.name ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      subTopic?.isLearnComplete == 1
                          ? Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    color: turquoise,
                                  ),
                                ),
                                GameButtonComponent(onClick: () {
                                  Navigator.pushNamed(
                                      context, GameVocabularyScreen.routeName,
                                      arguments: subTopic?.id.toString());
                                }),
                                SizedBox(
                                  width: 30,
                                )
                              ],
                            )
                          : SizedBox(
                              height: 20,
                            ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 50),
                        child: Text(
                          subTopic?.number_word ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            isLast
                ? SizedBox(
                    height: 30,
                  )
                : Container(
                    width: 5,
                    height: 50,
                    margin: EdgeInsets.only(left: sizeCircle / 2 + marginLeft),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(3.141),
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: LinearProgressIndicator(
                          value: subTopic?.processLearn,
                          valueColor: AlwaysStoppedAnimation(turquoise),
                          backgroundColor: disable,
                        ),
                      ),
                    ),
                  )
          ],
        );
      },
    );
  }
}
