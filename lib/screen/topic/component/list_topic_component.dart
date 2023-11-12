import 'package:english_study/constants.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
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
    return GridView.builder(
      padding: EdgeInsets.only(top: 50, left: 4, right: 4),
      physics: BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          crossAxisCount: 2,
          childAspectRatio: .8),
      itemBuilder: (context, index) {
        return widgetItemTopic(topics?[index]);
      },
      itemCount: topics?.length ?? 0,
    );
  }

  Widget widgetItemTopic(Topic? topic) {
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
            ),
          ))
        ],
      ),
    );
  }
}
