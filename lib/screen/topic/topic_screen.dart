import 'dart:io';

import 'package:english_study/model/topic.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/topic/component/list_topic_component.dart';
import 'package:english_study/screen/topic/topic_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatelessWidget {
  static String routeName = '/topic';
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BackScreenComponent(
              child: topicComponent(
                  ModalRoute.of(context)?.settings.arguments as String?,
                  hasBack: true),
            ),
          ],
        ),
      ),
    );
  }
}

Widget topicComponent(String? category,
    {List<Topic>? topics, bool hasBack = false}) {
  return Provider.value(
    value: TopicViewModel(),
    child: ListTopicComponent(
      category: category,
      topics: topics,
      hasBack: hasBack,
    ),
  );
}
