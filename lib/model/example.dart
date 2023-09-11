// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Example {
  String? sentence;
  Example({
    this.sentence,
  });

  Example copyWith({
    String? sentence,
  }) {
    return Example(
      sentence: sentence ?? this.sentence,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'example': sentence,
    };
  }

  factory Example.fromMap(Map<String, dynamic> map) {
    return Example(
      sentence: map['example'] != null ? map['example'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Example.fromJson(String source) => Example.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Example(sentence: $sentence)';

  @override
  bool operator ==(covariant Example other) {
    if (identical(this, other)) return true;
  
    return 
      other.sentence == sentence;
  }

  @override
  int get hashCode => sentence.hashCode;
}
