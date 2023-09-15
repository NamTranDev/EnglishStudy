import 'dart:async';

import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

class SubTopicViewModel {
  StreamController<List<SubTopic>> _subTopicListController = StreamController();
  Stream<List<SubTopic>> get subTopicsList => _subTopicListController.stream;

  Future<void> initData(String? topicId) async {
    var db = getIt<DBProvider>();
    List<SubTopic> topics = await db.getSubTopics(topicId);
    _subTopicListController.sink.add(topics);
  }

  Future<void> dispose() => _subTopicListController.close();
}
