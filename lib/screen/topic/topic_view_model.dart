import 'dart:async';

import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

class TopicViewModel {
  StreamController<List<Topic>> _topicListController = StreamController();
  Stream<List<Topic>> get topicsList => _topicListController.stream;

  Future<void> initData(String? category) async {
    var db = getIt<DBProvider>();
    List<Topic> topics = await db.getTopics(category);
    _topicListController.sink.add(topics);
  }

  Future<void> dispose() => _topicListController.close();

  Future<bool> syncTopic(String? topicId) async {
    var db = getIt<DBProvider>();
    return db.syncTopic(topicId);
  }
}
