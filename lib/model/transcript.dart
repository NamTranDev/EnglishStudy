import 'dart:convert';

class Transcript {
  int? conversation_id;
  String? script;
  Transcript({
    this.conversation_id,
    this.script,
  });

  Transcript copyWith({
    int? conversation_id,
    String? script,
  }) {
    return Transcript(
      conversation_id: conversation_id ?? this.conversation_id,
      script: script ?? this.script,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'conversation_id': script,
      'script': script,
    };
  }

  factory Transcript.fromMap(Map<String, dynamic> map) {
    return Transcript(
      conversation_id:
          map['conversation_id'] != null ? map['conversation_id'] as int : null,
      script: map['script'] != null ? map['script'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transcript.fromJson(String source) =>
      Transcript.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Transcript(conversation_id: $conversation_id,script: $script,)';

  @override
  bool operator ==(covariant Transcript other) {
    if (identical(this, other)) return true;

    return other.conversation_id == conversation_id && other.script == script;
  }

  @override
  int get hashCode => conversation_id.hashCode ^ script.hashCode;
}
