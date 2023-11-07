import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/sub_topic/sub_topic_view_model.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ListSubTopicComponent extends StatefulWidget {
  final String? topicId;
  const ListSubTopicComponent({super.key, this.topicId});

  @override
  State<ListSubTopicComponent> createState() => _ListSubTopicComponentState();
}

class _ListSubTopicComponentState extends State<ListSubTopicComponent> {
  SubTopicViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _viewModel = Provider.of<SubTopicViewModel>(context, listen: false);
    _viewModel?.initData(widget.topicId);
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubTopicViewModel>(
      builder: (context, viewmodel, child) {
        return StreamBuilder(
          stream: viewmodel.subTopicsList,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.hasData) {
              return Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(top: 50),
                    itemBuilder: (context, index) {
                      return widgetSubTopicItem(snapshot.data?[index]);
                    },
                    itemCount: snapshot.data?.length ?? 0,
                  ),
                  Positioned(
                      top: 10,
                      left: 10,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: widgetIcon('assets/icons/ic_arrow_prev.svg'),
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

  Widget widgetSubTopicItem(SubTopic? subTopic) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (subTopic?.image != null) widgetImage(subTopic?.image),
                Text(
                  subTopic?.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  subTopic?.number_word ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (subTopic?.isLearning == 1 || subTopic?.isLearnComplete == 1)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, GameVocabularyScreen.routeName,
                          arguments: subTopic?.id.toString());
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          widgetIcon('assets/icons/ic_game.svg'),
                          Text('Learn ')
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (subTopic?.isLearning == 0 && subTopic?.isLearnComplete == 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: widgetIcon('assets/icons/ic_lock.svg',
                      size: 60, color: Colors.white),
                ),
              ),
            ),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (subTopic?.isLearnComplete == 0 &&
                    subTopic?.isLearning == 0) {
                  return;
                }

                var subTopicId = subTopic?.id.toString();

                await Navigator.pushNamed(context, FlashCardScreen.routeName,
                    arguments: subTopicId);

                if (subTopic?.isLearnComplete == 1) {
                  return;
                }
                if (await _viewModel?.syncSubTopic(subTopicId) == true) {
                  _viewModel?.initData(widget.topicId);
                }
              },
            ),
          ))
        ],
      ),
    );
  }
}
