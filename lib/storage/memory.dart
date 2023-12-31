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

  int getCurrentTab() {
    var indexTab = currentTab ?? 0;
    currentTab = null;
    return indexTab;
  }
}
