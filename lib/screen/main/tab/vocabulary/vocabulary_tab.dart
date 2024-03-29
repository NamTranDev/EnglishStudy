import 'package:english_study/model/topic_type.dart';
import 'package:english_study/screen/category/category_component.dart';
import 'package:english_study/screen/main/tab/vocabulary/vocabulary_tab_viewmodel.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VocabularyTab extends StatefulWidget {
  const VocabularyTab({super.key});

  @override
  State<VocabularyTab> createState() => _VocabularyTabState();
}

class _VocabularyTabState extends State<VocabularyTab>
    with AutomaticKeepAliveClientMixin<VocabularyTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<VocabularyTabViewModel>(
      builder: (context, viewmodel, _) {
        return FutureBuilder(
            future: viewmodel.initScreen(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Something wrong with message: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data;
                if (data?.pickCategory == true) {
                  return CategoryComponent(
                    onPickCategory: () {
                      setState(() {});
                    },
                    type: TopicType.VOCABULARY.value,
                  );
                } else {
                  if (data?.category == null) {
                    return Center(
                      child: Text(
                          "Something wrong with message: ${snapshot.error.toString()}"),
                    );
                  }
                  var topics = data?.topics;

                  if (topics?.length == 1) {
                    return SafeArea(
                        child: subTopicComponent(topics?.getOrNull(0),
                            fromTab: true));
                  }
                  return SafeArea(
                    child: topicComponent(
                      data?.category,
                      type: TopicType.VOCABULARY.value,
                      topics: topics,
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    );
  }
}
