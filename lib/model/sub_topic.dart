// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SubTopic {
  int? id;
  String? name;
  String? number_word;
  SubTopic({
    this.id,
    this.name,
    this.number_word,
  });

  SubTopic copyWith({
    int? id,
    String? name,
    String? number_word,
  }) {
    return SubTopic(
      id: id ?? this.id,
      name: name ?? this.name,
      number_word: number_word ?? this.number_word,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'topic_id': id,
      'sub_topic_name': name,
      'number_sub_topic_words': number_word,
    };
  }

  factory SubTopic.fromMap(Map<String, dynamic> map) {
    return SubTopic(
      id: map['topic_id'] != null ? map['topic_id'] as int : null,
      name: map['sub_topic_name'] != null ? map['sub_topic_name'] as String : null,
      number_word: map['number_sub_topic_words'] != null ? map['number_sub_topic_words'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SubTopic.fromJson(String source) => SubTopic.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SubTopic(id: $id, name: $name, number_word: $number_word)';

  @override
  bool operator ==(covariant SubTopic other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.number_word == number_word;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ number_word.hashCode;
}
