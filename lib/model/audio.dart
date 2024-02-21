// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:drift/drift.dart';

class Audio extends Table{
  String? name;
  String? path;
  Audio({
    this.name,
    this.path,
  });

  Audio copyWith({
    String? name,
    String? path,
  }) {
    return Audio(
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'audio_file_name': name,
      'audio_file_path': path,
    };
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      name: map['audio_file_name'] != null ? map['audio_file_name'] as String : null,
      path: map['audio_file_path'] != null ? map['audio_file_path'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) =>
      Audio.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Audio(audio_file_name: $name,audio_file_path: $path,)';

  @override
  bool operator ==(covariant Audio other) {
    if (identical(this, other)) return true;

    return other.name == name && other.path == path;
  }

  @override
  int get hashCode => name.hashCode ^ path.hashCode;
}
