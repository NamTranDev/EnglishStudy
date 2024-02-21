// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:drift/drift.dart';

class Spelling extends Table{
  String? spelling;
  Spelling({
    this.spelling,
  });

  Spelling copyWith({
    String? spelling,
  }) {
    return Spelling(
      spelling: spelling ?? this.spelling,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'spelling_text': spelling,
    };
  }

  factory Spelling.fromMap(Map<String, dynamic> map) {
    return Spelling(
      spelling: map['spelling_text'] != null ? map['spelling_text'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Spelling.fromJson(String source) => Spelling.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Spelling(text: $spelling)';

  @override
  bool operator ==(covariant Spelling other) {
    if (identical(this, other)) return true;
  
    return 
      other.spelling == spelling;
  }

  @override
  int get hashCode => spelling.hashCode;
}
