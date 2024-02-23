import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/init_screen_tab.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/cupertino.dart';

class ListenTabViewModel with ChangeNotifier {
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
