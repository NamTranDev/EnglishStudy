import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/model/init_screen_tab.dart';
import 'package:english_study/screen/listening/lessions/lession_topic_screen.dart';
import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:english_study/screen/category/category_component.dart';
import 'package:english_study/screen/vocabulary/sub_topic/sub_topic_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListenerTab extends StatefulWidget {
  const ListenerTab({super.key});

  @override
  State<ListenerTab> createState() => _ListenerTabState();
}

class _ListenerTabState extends State<ListenerTab>
    with AutomaticKeepAliveClientMixin<ListenerTab> {
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
              return CategoryComponent(
                onPickCategory: () {
                  setState(() {});
                },
                type: TabType.LISTEN.value,
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
                    child:
                        lessionsComponent(topics?.getOrNull(0), fromTab: true));
              }
              return SafeArea(
                  child: topicComponent(data?.category, TabType.LISTEN.value,
                      topics: topics));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<InitScreenTab> initScreen() async {
    var category = getIt<Preference>().currentCategory(TabType.LISTEN.value);
    if (category == null) {
      return InitScreenTab(pickCategory: true);
    }
    var topics = await getIt<DBProvider>().getTopics(
      category,
      TabType.LISTEN.value,
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
