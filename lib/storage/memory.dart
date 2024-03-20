import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

Future<AppMemory> initMemory() async {
  AppMemory appMemory = AppMemory._();
  appMemory.pathFolderDocument =
      (await getApplicationDocumentsDirectory()).path;
  return appMemory;
}

class AppMemory {
  AppMemory._();

  late String pathFolderDocument;

  Map<String, int>? folderSize;

  int? currentTab;

  final ValueNotifier<bool> isHasUpdate = ValueNotifier<bool>(false);

  int _numberAd = 0;

  int getCurrentTab() {
    var indexTab = currentTab ?? 0;
    currentTab = null;
    return indexTab;
  }

  bool checkShowAdInterested(int? value) {
    int max = value ?? 1;
    int random = Random().nextInt(3) + 1;
    _numberAd += random;
    if (_numberAd % (5 * max) == 0 || _numberAd % (8 * max) == 0) {
      _numberAd = 0;
      return true;
    }
    return false;
  }
}
