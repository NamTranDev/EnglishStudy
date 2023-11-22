// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Topic {
  int? id;
  String? name;
  String? image;
  String? number_sub_topic;
  String? total_word;
  String? description;
  String? link_resource;
  int? folder_size;
  int? isLearnComplete;
  int? isLearning;
  bool isDownload = false;
  Topic({
    this.id,
    this.name,
    this.image,
    this.number_sub_topic,
    this.total_word,
    this.description,
    this.link_resource,
    this.folder_size,
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
    String? link_resource,
    int? folder_size,
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
      link_resource: link_resource ?? this.link_resource,
      folder_size: folder_size ?? this.folder_size,
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
      'link_topic': link_resource,
      'length': folder_size,
      'isLearnComplete': isLearnComplete,
      'isLearning': isLearning,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['topic_name'] != null ? map['topic_name'] as String : null,
      image: map['topic_image'] != null ? map['topic_image'] as String : null,
      number_sub_topic: map['number_lessons'] != null
          ? map['number_lessons'] as String
          : null,
      total_word:
          map['total_words'] != null ? map['total_words'] as String : null,
      description: map['description_topic'] != null
          ? map['description_topic'] as String
          : null,
      link_resource:
          map['link_topic'] != null ? map['link_topic'] as String : null,
      folder_size:
          map['length'] != null ? map['length'] as int : null,
      isLearnComplete:
          map['isLearnComplete'] != null ? map['isLearnComplete'] as int : null,
      isLearning: map['isLearning'] != null ? map['isLearning'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Topic.fromJson(String source) =>
      Topic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Topic(id: $id, name: $name, image: $image, number_sub_topic: $number_sub_topic, total_word: $total_word, description: $description,link_resource: $link_resource,folder_size: $folder_size, isLearnComplete: $isLearnComplete, isLearning: $isLearning)';
  }

  @override
  bool operator ==(covariant Topic other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.image == image &&
        other.number_sub_topic == number_sub_topic &&
        other.total_word == total_word &&
        other.description == description &&
        other.link_resource == link_resource &&
        other.folder_size == folder_size &&
        other.isLearning == isLearning &&
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
        link_resource.hashCode ^
        folder_size.hashCode ^
        isLearning.hashCode ^
        isLearnComplete.hashCode;
  }
}
