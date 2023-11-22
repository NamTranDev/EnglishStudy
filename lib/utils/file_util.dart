import 'dart:io';

import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/memory.dart';

Future<bool> doesFileExist(String filePath) async {
  File file = File(filePath);
  return await file.exists();
}

Future<bool> doesFolderExist(String folderPath) async {
  Directory directory = Directory(folderPath);
  return await directory.exists();
}

Future<bool> equalSizeFolder(String folderPath, int fileSizeCheck) async {
  Directory directory = Directory(folderPath);

  int size = 0;

  if (directory.existsSync()) {
    var folderSizeMemory = getIt<AppMemory>().folderSize;
    print(folderSizeMemory);
    var isExist = (folderSizeMemory?[folderPath] ?? 0) >= fileSizeCheck;
    print(isExist);
    if (isExist) return true;
    await for (FileSystemEntity entity in directory.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    if (size >= fileSizeCheck) {
      getIt<AppMemory>().folderSize ??= <String, int>{};
      getIt<AppMemory>().folderSize?[folderPath] = size;
      print(getIt<AppMemory>().folderSize);
      return true;
    }
    directory.delete();
    return false;
  } else {
    return false;
  }
}
