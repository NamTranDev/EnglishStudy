// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:drift/drift.dart';

class Example extends Table{
  String? sentence;
  String? sentence_note;
  Example({
    this.sentence,
    this.sentence_note,
  });

  Example copyWith({
    String? sentence,
    String? sentence_note,
  }) {
    return Example(
      sentence: sentence ?? this.sentence,
      sentence_note: sentence_note ?? this.sentence_note,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'example': sentence,
      'example_note': sentence_note,
    };
  }

  factory Example.fromMap(Map<String, dynamic> map) {
    return Example(
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
      'Example(sentence: $sentence,sentence_note: $sentence_note)';

  @override
  bool operator ==(covariant Example other) {
    if (identical(this, other)) return true;

    return other.sentence == sentence && other.sentence_note == sentence_note;
  }

  @override
  int get hashCode => sentence.hashCode ^ sentence_note.hashCode;
}
