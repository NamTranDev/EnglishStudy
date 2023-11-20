import 'package:english_study/constants.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListTopicComponent extends StatelessWidget {
  final String? category;
  ListTopicComponent({super.key, this.category});

  late TopicViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<TopicViewModel>(
      builder: (context, viewmodel, child) {
        _viewModel = viewmodel;
        return FutureBuilder(
          future: viewmodel.initData(category),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.hasData) {
              return buildListTopic(context, snapshot.data);
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

  Widget buildListTopic(BuildContext context, List<Topic>? topics) {
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
                        padding: EdgeInsets.all(5),
                        child: ValueListenableBuilder(
                          valueListenable:
                              _viewModel.downloadManager.processAll,
                          builder: (context, value, child) {
                            print(value);
                            return value == null
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                              'Download all lession of category'),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _viewModel.downloadAll();
                                        },
                                        child: Text('Download'),
                                      )
                                    ],
                                  )
                                : Text(value.toString());
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
              widgetImage(topic?.image, fit: BoxFit.fitHeight),
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
                        return;
                      }
                      var topicId = topic?.id.toString();
                      await Navigator.pushNamed(
                          context, SubTopicScreen.routeName,
                          arguments: topicId);
                      if (topic?.isLearnComplete == 1) {
                        return;
                      }
                      await _viewModel.syncTopic(topicId);
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: ValueListenableBuilder(
                  valueListenable: _viewModel.downloadManager.processItems,
                  builder: (context, value, child) {
                    var info = value?[topic?.link_resource];
                    return info == null
                        ? SizedBox()
                        : widgetDownload(
                            info,
                            topic?.isLearnComplete == 0 &&
                                topic?.isLearning == 0);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget widgetDownload(FileInfo fileInfo, bool isLock) {
    switch (fileInfo.status) {
      case DownloadStatus.NONE:
        return ElevatedButton(
          onPressed: () {
            _viewModel.downloadTopic(fileInfo);
          },
          child: Icon(
            Icons.download,
            color: isLock ? Colors.white : Colors.black,
          ),
        );
      case DownloadStatus.DOWNLOADING:
        return Row(
          children: [
            Text(
              fileInfo.progress.toString(),
              style: TextStyle(color: isLock ? Colors.white : Colors.black),
            ),
            CircularProgressIndicator(
              color: turquoise,
              backgroundColor: isLock ? Colors.white : Colors.black,
              value: fileInfo.progress,
            )
          ],
        );
      default:
        return SizedBox();
    }
  }
}
