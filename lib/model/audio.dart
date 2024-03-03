import 'dart:convert';

class Audio {
  int? vocabulary_id;
  int? conversation_id;
  String? name;
  String? path;
  Audio({
    this.vocabulary_id,
    this.conversation_id,
    this.name,
    this.path,
  });

  Audio copyWith({
    int? vocabulary_id,
    int? conversation_id,
    String? name,
    String? path,
  }) {
    return Audio(
      vocabulary_id: vocabulary_id ?? this.vocabulary_id,
      conversation_id: conversation_id ?? this.conversation_id,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap(bool isConversation) {
    var data = <String, dynamic>{
      'audio_file_name': name,
      'audio_file_path': path,
    };
    if (isConversation) {
      data['conversation_id'] = conversation_id;
    } else {
      data['vocabulary_id'] = vocabulary_id;
    }
    return data;
  }

  factory Audio.fromMap(Map<String, dynamic> map, bool isConversation) {
    var data = Audio(
      name: map['audio_file_name'] != null
          ? map['audio_file_name'] as String
          : null,
      path: map['audio_file_path'] != null
          ? map['audio_file_path'] as String
          : null,
    );
    if (isConversation) {
      data.conversation_id =
          map['conversation_id'] != null ? map['conversation_id'] as int : null;
    } else {
      data.vocabulary_id =
          map['vocabulary_id'] != null ? map['vocabulary_id'] as int : null;
    }
    return data;
  }

  String toJson(bool isConversation) => json.encode(toMap(isConversation));

  factory Audio.fromJson(String source, bool isConversation) => Audio.fromMap(
      json.decode(source) as Map<String, dynamic>, isConversation);

  @override
  String toString() =>
      'Audio(vocabulary_id: $vocabulary_id,conversation_id: $conversation_id,audio_file_name: $name,audio_file_path: $path,)';

  @override
  bool operator ==(covariant Audio other) {
    if (identical(this, other)) return true;

    return other.vocabulary_id == vocabulary_id &&
        other.conversation_id == conversation_id &&
        other.name == name &&
        other.path == path;
  }

  @override
  int get hashCode =>
      vocabulary_id.hashCode ^
      conversation_id.hashCode ^
      name.hashCode ^
      path.hashCode;
}
