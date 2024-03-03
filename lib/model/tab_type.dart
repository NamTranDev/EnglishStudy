enum TopicType {
  VOCABULARY,
  LISTEN,
}

extension TypeTopicExtension on TopicType {
  int get value {
    switch (this) {
      case TopicType.VOCABULARY:
        return 0;
      case TopicType.LISTEN:
        return 1;
    }
  }
}
