import 'package:english_study/constants.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/component/download_banner_component.dart';
import 'package:english_study/reuse/component/download_process_component.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListTopicComponent extends StatefulWidget {
  final String? category;
  ListTopicComponent({super.key, this.category});

  @override
  State<ListTopicComponent> createState() => _ListTopicComponentState();
}

class _ListTopicComponentState extends State<ListTopicComponent> {
  late TopicViewModel _viewModel;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TopicViewModel>(
      builder: (context, viewmodel, child) {
        _viewModel = viewmodel;
        _viewModel.downloadManager.onDownloadErrorListener = () {
          showSnackBar(context, 'An error occurred during the download process',
              iconSvg: 'assets/icons/ic_error.svg', iconSvgColor: red_violet);
        };
        return FutureBuilder(
          future: viewmodel.initData(widget.category),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.hasData) {
              return buildListTopic(snapshot.data);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  Widget buildListTopic(List<Topic>? topics) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        ValueListenableBuilder(
          valueListenable: _viewModel.needDownload,
          builder: (context, value, child) {
            return value
                ? Card(
                    margin: EdgeInsets.only(left: 8, right: 8),
                    elevation: 5,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ValueListenableBuilder(
                          valueListenable:
                              _viewModel.downloadManager.processAll,
                          builder: (context, value, child) {
                            print(value);
                            return DownloadBannerComponent(
                              text: 'Download all lession',
                              process: value,
                              onDownloadClick: () {
                                _viewModel.downloadAll();
                              },
                            );
                          },
                        )),
                  )
                : SizedBox();
          },
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 8, left: 5, right: 5),
            child: GridView.builder(
              // physics: BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: 2,
                  childAspectRatio: .8),
              itemBuilder: (context, index) {
                return widgetItemTopic(topics?[index]);
              },
              itemCount: topics?.length ?? 0,
            ),
          ),
        )
      ],
    );
  }

  Widget widgetItemTopic(Topic? topic) {
    return ValueListenableBuilder(
      valueListenable: _viewModel.updateLessionStatus,
      builder: (context, value, child) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              widgetImage(topic?.name, topic?.image, fit: BoxFit.fitHeight),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    topic?.number_sub_topic ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 5,
                  ),
                  Text(
                    topic?.total_word ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 25,
                  ),
                ],
              ),
              if (topic?.isLearnComplete == 0 && topic?.isLearning == 0)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: widgetIcon('assets/icons/ic_lock.svg',
                        size: 60, color: Colors.white),
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (topic?.isLearnComplete == 0 &&
                          topic?.isLearning == 0) {
                        showSnackBar(
                            context, 'You need to study the open topics first');
                        return;
                      }
                      var isHasResource = _viewModel.downloadManager
                          .checkHasResource(topic?.link_resource);

                      var isDefault = topic?.isDefault == 1;

                      if (!isHasResource && !isDefault) {
                        showSnackBar(
                            context, 'You must download data lession first');
                        return;
                      }
                      await Navigator.pushNamed(
                          context, SubTopicScreen.routeName,
                          arguments: topic);
                      if (topic?.isLearnComplete == 1) {
                        return;
                      }
                      await _viewModel.syncTopic(topic);
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: ValueListenableBuilder(
                  valueListenable: _viewModel.downloadManager.processItems,
                  builder: (context, value, child) {
                    var info = value?[topic?.link_resource];
                    return widgetDownload(info,
                        topic?.isLearnComplete == 0 && topic?.isLearning == 0);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget widgetDownload(FileInfo? fileInfo, bool isLock) {
    switch (fileInfo?.status) {
      case DownloadStatus.NONE:
        return GestureDetector(
          onTap: () {
            _viewModel.downloadTopic(fileInfo);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2, color: isLock ? baby_powder : maastricht_blue)),
            alignment: Alignment.center,
            child: widgetIcon(
              'assets/icons/ic_download.svg',
              size: 24,
              color: isLock ? baby_powder : maastricht_blue,
            ),
          ),
        );
      case DownloadStatus.DOWNLOADING:
        return Container(
          width: 40,
          height: 40,
          child: DownloadComponent(
            process: fileInfo?.progress,
            colorProcess: isLock ? baby_powder : maastricht_blue,
          ),
        );
      default:
        return SizedBox();
    }
  }
}
