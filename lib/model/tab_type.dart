enum TabType {
  VOCABULARY,
  LISTEN,
}

extension TypeTabExtension on TabType {
  int get value {
    switch (this) {
      case TabType.VOCABULARY:
        return 0;
      case TabType.LISTEN:
        return 1;
    }
  }
}
