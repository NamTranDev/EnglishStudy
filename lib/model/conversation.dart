import 'dart:convert';

import 'package:english_study/model/audio.dart';
import 'package:english_study/model/transcript.dart';

class Conversation {
  int? id;
  int? topic_id;
  String? conversation_lession;
  int? isLearning;
  int? isLearnComplete;
  List<Audio>? audios;
  List<Transcript>? transcript;
  
  Conversation({
    this.id,
    this.topic_id,
    this.conversation_lession,
    this.isLearning,
    this.isLearnComplete,
  });

  Conversation copyWith({
    int? id,
    int? topic_id,
    String? conversation_lession,
    int? isLearning,
    int? isLearnComplete,
  }) {
    return Conversation(
      id: id ?? this.id,
      topic_id: topic_id ?? this.topic_id,
      conversation_lession: conversation_lession ?? this.conversation_lession,
      isLearning: isLearning ?? this.isLearning,
      isLearnComplete: isLearnComplete ?? this.isLearnComplete,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'topic_id': topic_id,
      'conversation_lession': conversation_lession,
      'isLearning': isLearning,
      'isLearnComplete': isLearnComplete,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] != null ? map['id'] as int : null,
      topic_id: map['topic_id'] != null ? map['topic_id'] as int : null,
      conversation_lession: map['conversation_lession'] != null
          ? map['conversation_lession'] as String
          : null,
      isLearning: map['isLearning'] != null ? map['isLearning'] as int : null,
      isLearnComplete: map['isLearnComplete'] != null ? map['isLearnComplete'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Conversation.fromJson(String source) =>
      Conversation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Conversation(id: $id,topic_id: $topic_id, conversation_lession: $conversation_lession, isLearning: $isLearning, isLearnComplete: $isLearnComplete)';

  @override
  bool operator ==(covariant Conversation other) {
    if (identical(this, other)) return true;

    return other.topic_id == topic_id && other.id == id &&
        other.conversation_lession == conversation_lession &&
        other.isLearning == isLearning &&
        other.isLearnComplete == isLearnComplete;
  }

  @override
  int get hashCode =>
      id.hashCode ^ topic_id.hashCode ^ conversation_lession.hashCode ^ isLearning.hashCode ^ isLearnComplete.hashCode;
}
