import 'package:english_study/constants.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/sub_topic/sub_topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListSubTopicComponent extends StatelessWidget {
  final Topic? topic;
  ListSubTopicComponent({super.key, this.topic});

  late SubTopicViewModel _viewModel;

  double marginLeft = 30;

  double sizeCircle = 120;

  int animationDuration = 2000;

  @override
  Widget build(BuildContext context) {
    return Consumer<SubTopicViewModel>(
      builder: (context, viewmodel, child) {
        _viewModel = viewmodel;
        return FutureBuilder(
          future: viewmodel.initData(topic?.id?.toString()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  ValueListenableBuilder(
                    valueListenable: _viewModel.downloadManager.processItems,
                    builder: (context, value, child) {
                      FileInfo? fileInfo = value?[topic?.link_resource];
                      return fileInfo != null &&
                              fileInfo.status != DownloadStatus.COMPLETE
                          ? Card(
                              margin: EdgeInsets.only(left: 8, right: 8),
                              elevation: 5,
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: fileInfo.status == DownloadStatus.NONE
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
                                                _viewModel.downloadManager
                                                    .download(
                                                        topic?.link_resource);
                                              },
                                              child: Text('Download'),
                                            )
                                          ],
                                        )
                                      : fileInfo.progress == 100
                                          ? SizedBox()
                                          : Text(fileInfo.progress
                                                  ?.toStringAsFixed(2) ??
                                              '')),
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
    );
  }

  Widget widgetSubTopicItem(List<SubTopic>? subTopics, int index) {
    SubTopic? subTopic = subTopics?[index];
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
                      return;
                    }

                    var subTopicId = subTopic?.id.toString();

                    await Navigator.pushNamed(
                        context, FlashCardScreen.routeName,
                        arguments: subTopicId);

                    if (subTopic?.isLearnComplete == 1) {
                      return;
                    }
                    if (await _viewModel.syncSubTopic(subTopicId) == true) {
                      _viewModel.updateSubTopicComplete(subTopics, index);
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
                                    subTopic?.folderName, subTopic?.image,
                                    fit: BoxFit.contain),
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
                          style: Theme.of(context).textTheme.bodyMedium,
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
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1, color: maastricht_blue),
                                  ),
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          GameVocabularyScreen.routeName,
                                          arguments: subTopic?.id.toString());
                                    },
                                    child: widgetIcon(
                                        'assets/icons/ic_game.svg',
                                        color: maastricht_blue),
                                  ),
                                ),
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
                          style: Theme.of(context).textTheme.bodySmall,
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
