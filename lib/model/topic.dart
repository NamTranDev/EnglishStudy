// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Topic {
  int? id;
  String? name;
  String? image;
  String? number_sub_topic;
  String? total_word;
  String? description;
  int? isLearnComplete;
  int? isLearning;
  Topic({
    this.id,
    this.name,
    this.image,
    this.number_sub_topic,
    this.total_word,
    this.description,
    this.isLearnComplete,
    this.isLearning,
  });

  Topic copyWith({
    int? id,
    String? name,
    String? image,
    String? number_sub_topic,
    String? total_word,
    String? description,
    int? isLearnComplete,
    int? isLearning,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      number_sub_topic: number_sub_topic ?? this.number_sub_topic,
      total_word: total_word ?? this.total_word,
      description: description ?? this.description,
      isLearnComplete: isLearnComplete ?? this.isLearnComplete,
      isLearning: isLearning ?? this.isLearning,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'topic_name': name,
      'topic_image': image,
      'number_lessons': number_sub_topic,
      'total_words': total_word,
      'description_topic': description,
      'isLearnComplete': isLearnComplete,
      'isLearning': isLearning,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['topic_name'] != null ? map['topic_name'] as String : null,
      image: map['topic_image'] != null ? map['topic_image'] as String : null,
      number_sub_topic: map['number_lessons'] != null ? map['number_lessons'] as String : null,
      total_word: map['total_words'] != null ? map['total_words'] as String : null,
      description: map['description_topic'] != null ? map['description_topic'] as String : null,
      isLearnComplete: map['isLearnComplete'] != null ? map['isLearnComplete'] as int : null,
      isLearning: map['isLearning'] != null ? map['isLearning'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Topic.fromJson(String source) => Topic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Topic(id: $id, name: $name, image: $image, number_sub_topic: $number_sub_topic, total_word: $total_word, description: $description, isLearnComplete: $isLearnComplete)';
  }

  @override
  bool operator ==(covariant Topic other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.image == image &&
      other.number_sub_topic == number_sub_topic &&
      other.total_word == total_word &&
      other.description == description &&
      other.isLearnComplete == isLearnComplete;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      image.hashCode ^
      number_sub_topic.hashCode ^
      total_word.hashCode ^
      description.hashCode ^
      isLearnComplete.hashCode;
  }
}