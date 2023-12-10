import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/vocabulary_init_data.dart';
import 'package:english_study/screen/category/category_screen.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return FutureBuilder(
        future: initScreen(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  "Something wrong with message: ${snapshot.error.toString()}"),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data;
            if (data?.pickCategory == true) {
              return CategoryScreen(
                onPickCategory: () {
                  setState(() {});
                },
                type: TabType.VOCABULARY.value,
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
                getIt<DownloadManager>()
                    .checkNeedDownload(data?.category, topics);
                return SafeArea(child: subTopicComponent(topics?[0]));
              }
              return SafeArea(
                child: topicComponent(
                  data?.category,
                  TabType.VOCABULARY.value,
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
  }

  Future<InitScreenTab> initScreen() async {
    var category =
        getIt<Preference>().currentCategory(TabType.VOCABULARY.value);
    if (category == null) {
      return InitScreenTab(pickCategory: true);
    }
    var topics = await getIt<DBProvider>().getTopics(
      category,
      TabType.VOCABULARY.value,
    );
    if (topics.length == 1) {
      await getIt<DownloadManager>().checkNeedDownload(category, topics);
    }
    return InitScreenTab(
      pickCategory: false,
      category: category,
      topics: topics,
    );
  }
}
