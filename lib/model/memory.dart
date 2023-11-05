import 'package:path_provider/path_provider.dart';

Future<AppMemory> initMemory() async {
  AppMemory appMemory = AppMemory._();
  appMemory.pathFolderDocument = (await getApplicationDocumentsDirectory()).path;
  return appMemory;
}

class AppMemory {
  AppMemory._();

  late String pathFolderDocument;
}
