import 'dart:convert';

class Spelling {
  int? vocabulary_id;
  String? spelling;
  Spelling({
    this.vocabulary_id,
    this.spelling,
  });

  Spelling copyWith({
    int? vocabulary_id,
    String? spelling,
  }) {
    return Spelling(
      vocabulary_id: vocabulary_id ?? this.vocabulary_id,
      spelling: spelling ?? this.spelling,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vocabulary_id': vocabulary_id,
      'spelling_text': spelling,
    };
  }

  factory Spelling.fromMap(Map<String, dynamic> map) {
    return Spelling(
      vocabulary_id: map['vocabulary_id'] != null ? map['vocabulary_id'] as int : null,
      spelling: map['spelling_text'] != null ? map['spelling_text'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Spelling.fromJson(String source) => Spelling.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Spelling(vocabulary_id: $vocabulary_id,text: $spelling)';

  @override
  bool operator ==(covariant Spelling other) {
    if (identical(this, other)) return true;
  
    return 
      other.vocabulary_id == vocabulary_id && other.spelling == spelling;
  }

  @override
  int get hashCode => vocabulary_id.hashCode ^ spelling.hashCode;
}
