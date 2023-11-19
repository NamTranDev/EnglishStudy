import 'dart:io';

Future<bool> doesFileExist(String filePath) async {
  File file = File(filePath);
  return await file.exists();
}

Future<bool> doesFolderExist(String folderPath) async {
  Directory directory = Directory(folderPath);
  return await directory.exists();
}
