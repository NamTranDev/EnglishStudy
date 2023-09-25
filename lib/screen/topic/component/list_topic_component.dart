import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
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
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return buildListTopic(context, snapshot.data);
            }
          },
        );
      },
    );
  }

  Widget buildListTopic(BuildContext context, List<Topic>? topics) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                if (topics?[index].isLearnComplete == 0 && topics?[index].isLearning == 0) {
                  return;
                }
                var topicId = topics?[index].id.toString();
                await Navigator.pushNamed(context, SubTopicScreen.routeName,
                    arguments: topicId);
                if (topics?[index].isLearnComplete == 1) {
                  return;
                }
                if (await _viewModel?.syncTopic(topicId) == true) {
                  _viewModel?.initData(widget.category);
                }
              },
              child: Text(
                topics?[index].name ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: topics?[index].isLearning == 1 || topics?[index].isLearnComplete == 1 ? Colors.black : Colors.red),
              ),
            ),
          ),
        );
      },
      itemCount: topics?.length ?? 0,
    );
  }
}
