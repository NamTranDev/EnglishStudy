// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Audio {
  String? path;
  String? folderName;
  Audio({
    this.path,
  });

  Audio copyWith({
    String? path,
  }) {
    return Audio(
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'audio_file': path,
    };
  }

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
      path: map['audio_file'] != null ? map['audio_file'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Audio.fromJson(String source) =>
      Audio.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Audio(path: $path)';

  @override
  bool operator ==(covariant Audio other) {
    if (identical(this, other)) return true;

    return other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
