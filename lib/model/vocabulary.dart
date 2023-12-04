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
  String? image_file_name;
  String? image_file_path;
  String? word_type;
  String? description;
  int? isLearn;
  List<Audio>? audios;
  List<Spelling>? spellings;
  List<Example>? examples;

  String? folderName;

  Vocabulary({
    this.id,
    this.sub_topic_id,
    this.word,
    this.image_file_name,
    this.image_file_path,
    this.word_type,
    this.description,
    this.isLearn,
  });

  Vocabulary copyWith({
    int? id,
    int? sub_topic_id,
    String? word,
    String? image_file_name,
    String? image_file_path,
    String? word_type,
    String? description,
    int? isLearn,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      sub_topic_id: sub_topic_id ?? this.sub_topic_id,
      word: word ?? this.word,
      image_file_name: image_file_name ?? this.image_file_name,
      image_file_path: image_file_path ?? this.image_file_path,
      word_type: word_type ?? this.word_type,
      description: description ?? this.description,
      isLearn: isLearn ?? this.isLearn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sub_topic_id': sub_topic_id,
      'vocabulary': word,
      'image_file_name': image_file_name,
      'image_file_path': image_file_path,
      'word_type': word_type,
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
      image_file_name: map['image_file_name'] != null ? map['image_file_name'] as String : null,
      image_file_path: map['image_file_path'] != null ? map['image_file_path'] as String : null,
      word_type: map['word_type'] != null ? map['word_type'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      isLearn: map['isLearn'] != null ? map['isLearn'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vocabulary.fromJson(String source) =>
      Vocabulary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vocabulary(id: $id, sub_topic_id: $sub_topic_id, word: $word, image_file_name: $image_file_name, image_file_path: $image_file_path, word_type: $word_type, description: $description, isLearn: $isLearn)';
  }

  @override
  bool operator ==(covariant Vocabulary other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.sub_topic_id == sub_topic_id &&
        other.word == word &&
        other.image_file_name == image_file_name &&
        other.image_file_path == image_file_path &&
        other.word_type == word_type &&
        other.description == description &&
        other.isLearn == isLearn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sub_topic_id.hashCode ^
        word.hashCode ^
        image_file_name.hashCode ^
        image_file_path.hashCode ^
        word_type.hashCode ^
        description.hashCode ^
        isLearn.hashCode;
  }
}
