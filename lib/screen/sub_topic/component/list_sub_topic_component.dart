import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/game/game_vocabulary_screen.dart';
import 'package:english_study/screen/sub_topic/sub_topic_view_model.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
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
              return buildListSubTopic(context, snapshot.data);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  Widget buildListSubTopic(BuildContext context, List<SubTopic>? subTopics) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                if (subTopics?[index].isLearnComplete == 0 &&
                    subTopics?[index].isLearning == 0) {
                  return;
                }

                var subTopicId = subTopics?[index].id.toString();

                await Navigator.pushNamed(context, FlashCardScreen.routeName,
                    arguments: subTopicId);

                if (subTopics?[index].isLearnComplete == 1) {
                  return;
                }
                if (await _viewModel?.syncSubTopic(subTopicId) == true) {
                  _viewModel?.initData(widget.topicId);
                }
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        subTopics?[index].name ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: subTopics?[index].isLearning == 1 ||
                                    subTopics?[index].isLearnComplete == 1
                                ? Colors.black
                                : Colors.red),
                      ),
                    ),
                  ),
                  if (subTopics?[index].isLearnComplete == 1)
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, GameVocabularyScreen.routeName,
                                arguments: subTopics?[index].id.toString());
                          },
                          child: Card(
                            child: Center(
                              child: Text(
                                'Play game',
                                style: TextStyle(color: Colors.blue),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: subTopics?.length ?? 0,
    );
  }
}
