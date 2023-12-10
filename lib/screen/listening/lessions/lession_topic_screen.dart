import 'package:english_study/model/topic.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/listening/lessions/component/list_lession_component.dart';
import 'package:english_study/screen/listening/lessions/lession_topic_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LessionTopicScreen extends StatefulWidget {
  static String routeName = '/lession_topic';
  const LessionTopicScreen({super.key});

  @override
  State<LessionTopicScreen> createState() => _LessionTopicScreenState();
}

class _LessionTopicScreenState extends State<LessionTopicScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackScreenComponent(
          child: lessionsComponent(
              ModalRoute.of(context)?.settings.arguments as Topic?,
              hasBack: true),
        ),
      ),
    );
  }
}

Widget lessionsComponent(Topic? topic, {bool hasBack = false}) {
  return Provider.value(
    value: LessionTopicViewModel(),
    child: ListLessionComponent(
      topic: topic,
      hasBack: hasBack,
    ),
  );
}