import 'package:english_study/audio/player_manager.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/check_complete_category.dart';
import 'package:english_study/reuse/component/banner_component.dart';
import 'package:english_study/reuse/component/download_banner_component.dart';
import 'package:english_study/reuse/component/header_title_component.dart';
import 'package:english_study/reuse/component/next_category_component.dart';
import 'package:english_study/screen/listening/conversation/argument.dart';
import 'package:english_study/screen/listening/conversation/conversation_background_screen.dart';
import 'package:english_study/screen/listening/conversation/conversation_screen.dart';
import 'package:english_study/screen/listening/lessions/lession_topic_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

class ListLessionComponent extends StatefulWidget {
  final Topic? topic;
  final bool fromTab;
  const ListLessionComponent({super.key, this.topic, required this.fromTab});

  @override
  State<ListLessionComponent> createState() => _ListLessionComponentState();
}

class _ListLessionComponentState extends State<ListLessionComponent> {
  late LessionTopicViewModel _viewModel;
  final tooltipController = JustTheController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<LessionTopicViewModel>(
            builder: (context, viewmodel, child) {
              _viewModel = viewmodel;
              _viewModel.downloadManager.onDownloadErrorListener = () {
                showSnackBar(
                    context, 'An error occurred during the download process',
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
                                    text: 'Learn Another Topic',
                                    onNextCategoryClick: () {
                                      nextPickCategory(context, widget.topic);
                                    },
                                  )
                                : const SizedBox();
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
                                    margin: EdgeInsets.only(
                                        left: 8, right: 8, bottom: 10),
                                    elevation: 5,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: DownloadBannerComponent(
                                        text: 'Download this lession',
                                        process: fileInfo.progress,
                                        onDownloadClick: () {
                                          _viewModel.downloadManager.download(
                                              widget.topic?.link_resource);
                                        },
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                        Expanded(
                            child: ListView.builder(
                          itemBuilder: (context, index) {
                            // print(snapshot.data?.length);
                            // print(index);
                            // print(isLast);
                            return widgetLessionItem(snapshot.data, index);
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

  Widget widgetLessionItem(List<Conversation>? conversations, int index) {
    Conversation? conversation = conversations?.getOrNull(index);
    return ValueListenableBuilder(
      valueListenable: _viewModel.updateLessionStatus,
      builder: (context, value, child) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Container(
                height: 120,
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  conversation?.conversation_lession ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 20),
                ),
              ),
              if (conversation?.isLearnComplete == 0 &&
                  conversation?.isLearning == 0)
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    alignment: Alignment.center,
                    child: widgetIcon('assets/icons/ic_lock.svg',
                        size: 60, color: Colors.white),
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (conversation?.isLearnComplete == 0 &&
                          conversation?.isLearning == 0) {
                        showSnackBar(
                            context, 'You need to study the open topics first');
                        return;
                      }

                      var isHasResource = _viewModel.downloadManager
                          .checkHasResource(widget.topic?.link_resource);

                      var isDefault = index < 5 && widget.topic?.isDefault == 1;

                      if (!isHasResource && !isDefault) {
                        showSnackBar(
                            context, 'You must download data lession first');
                        return;
                      }

                      var id = conversation?.id?.toString();

                      var iPref = getIt<Preference>();
                      logger(conversations);
                      logger(isHasResource);
                      logger(iPref.isConversationBackground());
                      if (conversations != null &&
                          isHasResource &&
                          iPref.isConversationBackground()) {
                        logger(conversation);
                        if (conversation?.audios == null ||
                            conversation?.transcript == null) {
                          conversations = await _viewModel.getData(
                              widget.topic, widget.fromTab);
                        }

                        await Navigator.pushNamed(
                            context, ConversationBackgroundScreen.routeName,
                            arguments: ScreenConversationArguments(
                                conversations, conversation));
                      } else {
                        await Navigator.pushNamed(
                            context, ConversationScreen.routeName,
                            arguments: conversation);
                      }

                      if (conversation?.isLearnComplete == 1) {
                        return;
                      }

                      if (await _viewModel.syncLession(id)) {
                        _viewModel.updateComplete(
                            conversations, index, widget.topic);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
