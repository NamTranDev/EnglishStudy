import 'dart:io';
import 'dart:typed_data';

import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/memory.dart';
import 'package:flutter/services.dart';

Future<bool> doesImageExistInAssets(String imagePath) async {
  try {
    // Simulate an asynchronous behavior with Future.delayed
    await Future.delayed(Duration.zero);

    // Attempt to load the asset.
    ByteData? data = await rootBundle.load(imagePath);

    // If data is not null, the file exists.
    return data != null;
  } catch (_) {
    // If an exception is thrown, the file does not exist.
    return false;
  }
}

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

  if (directory.existsSync()) {
    var folderSizeMemory = getIt<AppMemory>().folderSize;
    print(folderSizeMemory);
    var isExist = (folderSizeMemory?[folderPath] ?? 0) >= fileSizeCheck;
    print(isExist);
    if (isExist) return true;
    var size = await sizeDirectory(directory);
    if (size >= fileSizeCheck) {
      getIt<AppMemory>().folderSize ??= <String, int>{};
      getIt<AppMemory>().folderSize?[folderPath] = size;
      print(getIt<AppMemory>().folderSize);
      return true;
    }
    // directory.deleteSync(recursive: true);
    return false;
  } else {
    return false;
  }
}

Future<int> sizeDirectory(Directory dir) async {
  var files = await dir.list(recursive: true).toList();
  var dirSize = files.fold(0, (int sum, file) => sum + file.statSync().size);
  return dirSize;
}
