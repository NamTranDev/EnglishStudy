import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ListTopicComponent extends StatefulWidget {
  final String? category;
  const ListTopicComponent({super.key, this.category});

  @override
  State<ListTopicComponent> createState() => _ListTopicComponentState();
}

class _ListTopicComponentState extends State<ListTopicComponent> {
  TopicViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _viewModel = Provider.of<TopicViewModel>(context, listen: false);
    _viewModel?.initData(widget.category);
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TopicViewModel>(
      builder: (context, viewmodel, child) {
        return StreamBuilder(
          stream: viewmodel.topicsList,
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
    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.only(top: 50),
          itemBuilder: (context, index) {
            return widgetItemTopic(topics?[index]);
          },
          itemCount: topics?.length ?? 0,
        ),
        Positioned(
            top: 10,
            left: 15,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: widgetIcon('assets/icons/ic_arrow_prev.svg'),
            ))
      ],
    );
  }

  Widget widgetItemTopic(Topic? topic) {
    return InkWell(
      onTap: () async {
        if (topic?.isLearnComplete == 0 && topic?.isLearning == 0) {
          return;
        }
        var topicId = topic?.id.toString();
        await Navigator.pushNamed(context, SubTopicScreen.routeName,
            arguments: topicId);
        if (topic?.isLearnComplete == 1) {
          return;
        }
        if (await _viewModel?.syncTopic(topicId) == true) {
          _viewModel?.initData(widget.category);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 2, child: widgetImage(topic?.image)),
                        Expanded(
                            child: Text(
                          topic?.name ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        )),
                      ],
                    ),
                    if (topic?.isLearning == 0 && topic?.isLearnComplete == 0)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                              child: widgetIcon('assets/icons/ic_lock.svg',
                                  size: 100, color: Colors.white)),
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      topic?.number_sub_topic ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      topic?.total_word ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
