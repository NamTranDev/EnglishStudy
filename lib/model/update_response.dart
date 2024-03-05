// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/model/category.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/update_status.dart';

class UpdateReponse {
  UpdateStatus? status;
  Category? category;
  Topic? topic;
  double? process;
  UpdateReponse(
    this.status, {
    this.category,
    this.topic,
    this.process,
  });

  

  @override
  String toString() {
    return 'UpdateReponse(status: $status, category: $category, topic: $topic, process: $process)';
  }
}
