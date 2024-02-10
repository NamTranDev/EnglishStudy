// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ffi';

import 'package:english_study/model/audio.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/spelling.dart';
import 'package:flutter/material.dart';

class Vocabulary with ChangeNotifier {
  int? id;
  int? sub_topic_id;
  String? word;
  String? word_note;
  String? image_file_name;
  String? image_file_path;
  String? word_type;
  String? description;
  String? description_note;
  int? isLearn;
  List<Audio>? audios;
  List<Spelling>? spellings;
  List<Example>? examples;

  String? folderName;

  Vocabulary({
    this.id,
    this.sub_topic_id,
    this.word,
    this.word_note,
    this.image_file_name,
    this.image_file_path,
    this.word_type,
    this.description,
    this.description_note,
    this.isLearn,
  });

  Vocabulary copyWith({
    int? id,
    int? sub_topic_id,
    String? word,
    String? word_note,
    String? image_file_name,
    String? image_file_path,
    String? word_type,
    String? description,
    String? description_note,
    int? isLearn,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      sub_topic_id: sub_topic_id ?? this.sub_topic_id,
      word: word ?? this.word,
      word_note: word_note ?? this.word_note,
      image_file_name: image_file_name ?? this.image_file_name,
      image_file_path: image_file_path ?? this.image_file_path,
      word_type: word_type ?? this.word_type,
      description: description ?? this.description,
      description_note: description_note ?? this.description_note,
      isLearn: isLearn ?? this.isLearn,
    );
  }

  void update() {
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sub_topic_id': sub_topic_id,
      'vocabulary': word,
      'word_note': word_note,
      'image_file_name': image_file_name,
      'image_file_path': image_file_path,
      'word_type': word_type,
      'description': description,
      'description_note': description_note,
      'isLearn': isLearn,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] != null ? map['id'] as int : null,
      sub_topic_id:
          map['sub_topic_id'] != null ? map['sub_topic_id'] as int : null,
      word: map['vocabulary'] != null ? map['vocabulary'] as String : null,
      word_note: map['word_note'] != null ? map['word_note'] as String : null,
      image_file_name: map['image_file_name'] != null
          ? map['image_file_name'] as String
          : null,
      image_file_path: map['image_file_path'] != null
          ? map['image_file_path'] as String
          : null,
      word_type: map['word_type'] != null ? map['word_type'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      description_note: map['description_note'] != null
          ? map['description_note'] as String
          : null,
      isLearn: map['isLearn'] != null ? map['isLearn'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vocabulary.fromJson(String source) =>
      Vocabulary.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vocabulary(id: $id, sub_topic_id: $sub_topic_id, word: $word, word_note: $word_note, image_file_name: $image_file_name, image_file_path: $image_file_path, word_type: $word_type, description: $description, description_note: $description_note, isLearn: $isLearn)';
  }

  @override
  bool operator ==(covariant Vocabulary other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.sub_topic_id == sub_topic_id &&
        other.word == word &&
        other.word_note == word_note &&
        other.image_file_name == image_file_name &&
        other.image_file_path == image_file_path &&
        other.word_type == word_type &&
        other.description == description &&
        other.description_note == description_note &&
        other.isLearn == isLearn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sub_topic_id.hashCode ^
        word.hashCode ^
        word_note.hashCode ^
        image_file_name.hashCode ^
        image_file_path.hashCode ^
        word_type.hashCode ^
        description.hashCode ^
        description_note.hashCode ^
        isLearn.hashCode;
  }
}
