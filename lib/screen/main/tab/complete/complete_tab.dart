import 'package:english_study/model/category.dart';
import 'package:english_study/screen/category/category_component.dart';
import 'package:english_study/screen/topic/argument.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class CompleteTab extends StatefulWidget {
  const CompleteTab({super.key});

  @override
  State<CompleteTab> createState() => _CompleteTabState();
}

class _CompleteTabState extends State<CompleteTab> {
  @override
  Widget build(BuildContext context) {
    return CategoryComponent(
      onPickCategory: (Category category) async {
        var db = getIt<DBProvider>();

        var topics = await db.getTopicsComplete(category.key);
        if (topics.length == 1) {
          Navigator.pushNamed(context, SubTopicScreen.routeName,
              arguments: topics.getOrNull(0));
        } else {
          Navigator.pushNamed(context, TopicScreen.routeName,
              arguments: ScreenTopicArguments(category.key, topics));
        }
      },
      isComplete: true,
    );
  }
}
