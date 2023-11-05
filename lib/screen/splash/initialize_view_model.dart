import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/model/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class InitializeViewModel {
  final ValueNotifier<String> _processText =
      ValueNotifier<String>('Splash Screen');
  ValueNotifier<String> get processText => _processText;

  Future initialize() async {
    String fileName = 'CEFR_Wordlist.zip';
    String folderName = 'CEFR_Wordlist';

    String folderPath = getIt<AppMemory>().pathFolderDocument;

    final path = (await getTemporaryDirectory()).path;

    bool folderExists = await doesFolderExist("$folderPath/$folderName");
    if (!folderExists) {
      _processText.value = "Sync Data";
      final file = File('$path/$fileName');
      if (doesFileExist(file.path) == true) {
        file.delete();
      }

      Dio dio = Dio();
      await dio.download(
        "https://dl.dropboxusercontent.com/scl/fi/vevyxj1iv56p3agg6gar0/CEFR_Wordlist.zip?rlkey=kmgtwbn21khwbftwkfpr3xlcm&dl=0",
        file.path,
        onReceiveProgress: (count, total) {
          _processText.value =
              'Downloading: ${((count / total) * 100).toStringAsFixed(0)}%';

          if (count == total) {
            _processText.value = 'Downloading Completed';
          }
        },
      );

      print('Download success');
      var length = await file.length();
      print('file.length : ' + length.toString());

      final destinationDir = Directory(folderPath);
      try {
        _processText.value = 'Extract File Zip';
        await ZipFile.extractToDirectory(
            zipFile: file,
            destinationDir: destinationDir,
            onExtracting: (zipEntry, progress) {
              _processText.value =
                  'Extracting : ${progress.toStringAsFixed(1)}%';
              return ZipFileOperation.includeItem;
            });
      } catch (e) {
        print(e);
      }
    } else {
      Future.delayed(Duration(seconds: 2));
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
}
