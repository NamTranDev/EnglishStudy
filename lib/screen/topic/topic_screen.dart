import 'package:english_study/screen/topic/component/list_topic_component.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatelessWidget {
  static String routeName = '/topic';
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: TopicViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: ListTopicComponent(
            category: ModalRoute.of(context)?.settings.arguments as String?,
          ),
        ),
      ),
    );
  }
}
