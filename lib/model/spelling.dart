// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Spelling {
  String? text;
  Spelling({
    this.text,
  });

  Spelling copyWith({
    String? text,
  }) {
    return Spelling(
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'spelling_text': text,
    };
  }

  factory Spelling.fromMap(Map<String, dynamic> map) {
    return Spelling(
      text: map['spelling_text'] != null ? map['spelling_text'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Spelling.fromJson(String source) => Spelling.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Spelling(text: $text)';

  @override
  bool operator ==(covariant Spelling other) {
    if (identical(this, other)) return true;
  
    return 
      other.text == text;
  }

  @override
  int get hashCode => text.hashCode;
}
