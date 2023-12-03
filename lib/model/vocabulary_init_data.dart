// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/model/topic.dart';

class VocabularyInitScreen {
  bool pickCategory = false;
  String? category;
  List<Topic>? topics;
  VocabularyInitScreen({
    required this.pickCategory,
    this.category,
    this.topics,
  });
}
