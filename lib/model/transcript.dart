import 'dart:convert';

class Transcript {
  String? script;
  Transcript({
    this.script,
  });

  Transcript copyWith({
    String? script,
  }) {
    return Transcript(
      script: script ?? this.script,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'script': script,
    };
  }

  factory Transcript.fromMap(Map<String, dynamic> map) {
    return Transcript(
      script: map['script'] != null ? map['script'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transcript.fromJson(String source) =>
      Transcript.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Transcript(script: $script)';

  @override
  bool operator ==(covariant Transcript other) {
    if (identical(this, other)) return true;

    return other.script == script;
  }

  @override
  int get hashCode => script.hashCode;
}
