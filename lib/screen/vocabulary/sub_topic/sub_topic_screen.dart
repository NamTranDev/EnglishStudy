import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/vocabulary/sub_topic/component/list_sub_topic_component.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubTopicScreen extends StatefulWidget {
  static String routeName = '/subtopic';
  const SubTopicScreen({super.key});

  @override
  State<SubTopicScreen> createState() => _SubTopicScreenState();
}

class _SubTopicScreenState extends State<SubTopicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackScreenComponent(
          child: subTopicComponent(
              ModalRoute.of(context)?.settings.arguments as Topic?),
        ),
      ),
    );
  }
}

Widget subTopicComponent(Topic? topic, {bool fromTab = false}) {
  return Provider.value(
    value: SubTopicViewModel(),
    child: ListSubTopicComponent(
      topic: topic,
      fromTab: fromTab,
    ),
  );
}
