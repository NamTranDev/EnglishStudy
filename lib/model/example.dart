// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class Example with ChangeNotifier {
  int? vocabulary_id;
  String? sentence;
  String? sentence_note;
  Example({
    this.vocabulary_id,
    this.sentence,
    this.sentence_note,
  });

  void notify() {
    notifyListeners();
  }

  Example copyWith({
    int? vocabulary_id,
    String? sentence,
    String? sentence_note,
  }) {
    return Example(
      vocabulary_id: vocabulary_id ?? this.vocabulary_id,
      sentence: sentence ?? this.sentence,
      sentence_note: sentence_note ?? this.sentence_note,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vocabulary_id': vocabulary_id,
      'example': sentence,
      'example_note': sentence_note,
    };
  }

  factory Example.fromMap(Map<String, dynamic> map) {
    return Example(
      vocabulary_id: map['vocabulary_id'] != null ? map['vocabulary_id'] as int : null,
      sentence: map['example'] != null ? map['example'] as String : null,
      sentence_note:
          map['example_note'] != null ? map['example_note'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Example.fromJson(String source) =>
      Example.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Example(vocabulary_id: $vocabulary_id,sentence: $sentence,sentence_note: $sentence_note)';

  @override
  bool operator ==(covariant Example other) {
    if (identical(this, other)) return true;

    return other.vocabulary_id == vocabulary_id && other.sentence == sentence && other.sentence_note == sentence_note;
  }

  @override
  int get hashCode => vocabulary_id.hashCode ^ sentence.hashCode ^ sentence_note.hashCode;
}
