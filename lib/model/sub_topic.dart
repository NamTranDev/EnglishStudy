import 'dart:convert';

import 'package:english_study/model/vocabulary.dart';

class SubTopic {
  int? id;
  int? topic_id;
  String? name;
  String? image;
  String? number_word;
  int? isLearnComplete;
  int? isLearning;

  double? processLearn = 0;

  List<Vocabulary>? vocabularies;

  SubTopic({
    this.id,
    this.topic_id,
    this.name,
    this.image,
    this.number_word,
    this.isLearnComplete,
    this.isLearning,
  });

  SubTopic copyWith({
    int? id,
    int? topic_id,
    String? name,
    String? image,
    String? number_word,
    int? isLearnComplete,
    int? isLearning,
  }) {
    return SubTopic(
      id: id ?? this.id,
      topic_id: topic_id ?? this.topic_id,
      name: name ?? this.name,
      image: image ?? this.image,
      number_word: number_word ?? this.number_word,
      isLearnComplete: isLearnComplete ?? this.isLearnComplete,
      isLearning: isLearning ?? this.isLearning,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'topic_id': topic_id,
      'sub_topic_name': name,
      'sub_topic_image': image,
      'number_sub_topic_words': number_word,
      'isLearnComplete': isLearnComplete,
      'isLearning': isLearning,
    };
  }

  factory SubTopic.fromMap(Map<String, dynamic> map) {
    return SubTopic(
      id: map['id'] != null ? map['id'] as int : null,
      topic_id: map['topic_id'] != null ? map['topic_id'] as int : null,
      name: map['sub_topic_name'] != null
          ? map['sub_topic_name'] as String
          : null,
      image: map['sub_topic_image'] != null
          ? map['sub_topic_image'] as String
          : null,
      number_word: map['number_sub_topic_words'] != null
          ? map['number_sub_topic_words'] as String
          : null,
      isLearnComplete:
          map['isLearnComplete'] != null ? map['isLearnComplete'] as int : null,
      isLearning: map['isLearning'] != null ? map['isLearning'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubTopic.fromJson(String source) =>
      SubTopic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SubTopic(id: $id,topic_id: $topic_id, name: $name, image: $image, number_word: $number_word, isLearnComplete: $isLearnComplete, isLearning: $isLearning)';

  @override
  bool operator ==(covariant SubTopic other) {
    if (identical(this, other)) return true;

    return 
    other.id == id &&
    other.topic_id == topic_id &&
        other.name == name &&
        other.image == image &&
        other.number_word == number_word &&
        other.isLearnComplete == isLearnComplete &&
        other.isLearning == isLearning;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      topic_id.hashCode ^
      name.hashCode ^
      image.hashCode ^
      number_word.hashCode ^
      isLearnComplete.hashCode ^
      isLearning.hashCode;
}
