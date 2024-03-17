enum UpdateStatus { LOADING, UPDATE, COMPLETE, ERROR }

extension UpdateStatusExtension on UpdateStatus {
  int get value {
    switch (this) {
      case UpdateStatus.LOADING:
        return 0;
      case UpdateStatus.UPDATE:
        return 1;
      case UpdateStatus.COMPLETE:
        return 2;
      case UpdateStatus.ERROR:
        return 3;
    }
  }
}
