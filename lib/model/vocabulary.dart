// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ffi';

import 'package:english_study/model/audio.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/spelling.dart';

class Vocabulary {
  int? id;
  int? sub_topic_id;
  String? word;
  String? image;
  String? type;
  String? description;
  int? isLearn;
  List<Audio>? audios;
  List<Spelling>? spellings;
  List<Example>? examples;

  Vocabulary({
    this.id,
    this.sub_topic_id,
    this.word,
    this.image,
    this.type,
    this.description,
    this.isLearn,
  });

  Vocabulary copyWith({
    int? id,
    int? sub_topic_id,
    String? word,
    String? image,
    String? type,
    String? description,
    int? isLearn,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      sub_topic_id: sub_topic_id ?? this.sub_topic_id,
      word: word ?? this.word,
      image: image ?? this.image,
      type: type ?? this.type,
      description: description ?? this.description,
      isLearn: isLearn ?? this.isLearn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sub_topic_id': sub_topic_id,
      'vocabulary': word,
      'image': image,
      'type': type,
      'description': description,
      'isLearn': isLearn,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] != null ? map['id'] as int : null,
      sub_topic_id:
          map['sub_topic_id'] != null ? map['sub_topic_id'] as int : null,
      word: map['vocabulary'] != null ? map['vocabulary'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      isLearn: map['isLearn'] != null ? map['isLearn'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vocabulary.fromJson(String source) =>
      Vocabulary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vocabulary(id: $id, sub_topic_id: $sub_topic_id, word: $word, image: $image, type: $type, description: $description, isLearn: $isLearn)';
  }

  @override
  bool operator ==(covariant Vocabulary other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.sub_topic_id == sub_topic_id &&
        other.word == word &&
        other.image == image &&
        other.type == type &&
        other.description == description &&
        other.isLearn == isLearn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sub_topic_id.hashCode ^
        word.hashCode ^
        image.hashCode ^
        type.hashCode ^
        description.hashCode ^
        isLearn.hashCode;
  }
}
