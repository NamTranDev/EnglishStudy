enum UpdateStatus { LOADING, UPDATE, COMPLETE }

extension UpdateStatusExtension on UpdateStatus {
  int get value {
    switch (this) {
      case UpdateStatus.LOADING:
        return 0;
      case UpdateStatus.UPDATE:
        return 1;
      case UpdateStatus.COMPLETE:
        return 2;
    }
  }
}
