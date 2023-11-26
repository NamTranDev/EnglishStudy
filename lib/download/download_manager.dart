import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';

class DownloadManager {
  String? _category;
  int totalNeedDownload = 0;
  final ValueNotifier<double?> _processAll = ValueNotifier<double?>(null);
  ValueNotifier<double?> get processAll => _processAll;
  final ValueNotifier<Map<String?, FileInfo>?> _processItems =
      ValueNotifier<Map<String?, FileInfo>?>(null);
  ValueNotifier<Map<String?, FileInfo>?> get processItems => _processItems;

  void initFileInfos(String category, List<FileInfo> fileInfos) {
    if (_category == category) {
      // processAll.value = null;
      // var processCurrents = processItems.value;
      // if (processCurrents != null) {
      //   processCurrents.values
      //       .where((element) => element.status == DownloadStatus.COMPLETE)
      //       .forEach((element) {
      //     var fileInfo = fileInfos
      //         .where((fileInfo) =>
      //             fileInfo.status == DownloadStatus.NONE &&
      //             fileInfo.link == element.link)
      //         .firstOrNull;
      //     if (fileInfo != null) {
      //       processCurrents[fileInfo.link] = fileInfo;
      //     }
      //   });

      //   processItems.value = processCurrents;
      // }
      return;
    }

    _category = category;
    _processItems.value = fileInfos.fold({}, (map, fileInfo) {
      map?[fileInfo.link] = fileInfo;
      totalNeedDownload += fileInfo.status == DownloadStatus.NONE ? 1 : 0;
      return map;
    });
  }

  Future<void> downloadAll() async {
    if (_processItems.value == null) {
      return;
    }
    _processAll.value = 0.0;

    var processCurrents = processItems.value;

    if (processCurrents != null) {
      processCurrents.forEach((key, file) {
        if (file.status == DownloadStatus.COMPLETE ||
            file.status == DownloadStatus.DOWNLOADING) return;
        _downloadFile(file);
      });
    }
  }

  Future<void> download(String? link) async {
    if (link == null || _processItems.value == null) {
      return;
    }

    var fileInfoNeedDownload = _processItems.value?[link];
    if (fileInfoNeedDownload != null &&
        fileInfoNeedDownload.status == DownloadStatus.NONE) {
      await _downloadFile(fileInfoNeedDownload);
    }
  }

  Future<void> _downloadFile(FileInfo fileInfo) async {
    var link = fileInfo.link;
    if (link == null) return;
    fileInfo.status = DownloadStatus.DOWNLOADING;
    final file = File(fileInfo.filePath);

    Dio dio = Dio();

    await dio.download(
      link,
      file.path,
      onReceiveProgress: (count, total) {
        // print(total);
        var processCurrents = processItems.value;
        if (processCurrents != null) {
          var fileInfoCurrent = processCurrents[fileInfo.link];
          if (fileInfoCurrent != null) {
            var progress = (count / total) * 100;
            fileInfoCurrent.progress = progress / 2;

            processItems.value = Map.from(processCurrents);
            if (processAll.value != null && totalNeedDownload > 0) {
              updateProgressAll();
            }
          }
        }
      },
    );
    await extractFile(fileInfo, file);
  }

  void updateProgressAll() {
    var total = _processItems.value?.values
            .where((element) =>
                element.progress != null &&
                element.status == DownloadStatus.DOWNLOADING)
            .fold(0.0, (sum, item) => sum + (item.progress ?? 0)) ??
        0;

    _processAll.value = total / totalNeedDownload;
  }

  Future<void> extractFile(FileInfo fileInfo, File file) async {
    // print(fileInfo.folderPath);
    var directory = Directory(fileInfo.folderPath);
    await ZipFile.extractToDirectory(
      zipFile: file,
      destinationDir: directory,
      onExtracting: (zipEntry, progress) {
        var processCurrents = processItems.value;
        if (processCurrents != null) {
          var fileInfoCurrent = processCurrents[fileInfo.link];
          if (fileInfoCurrent != null) {
            var progressValue = (100 + progress) / 2;
            fileInfoCurrent.progress = progressValue;
            if (progress == 100) {
              fileInfoCurrent.status = DownloadStatus.COMPLETE;
              updateTotalDownload();
              updateLengthDatabase(fileInfo.link);
            }
            processItems.value = Map.from(processCurrents);

            if (processAll.value != null && totalNeedDownload > 0) {
              updateProgressAll();
            }
          }
        }
        return ZipFileOperation.includeItem;
      },
    );
    var size = await sizeDirectory(directory);
    print('size : ' + size.toString());
    file.delete();
  }

  void updateLengthDatabase(String? key) async {
    getIt<DBProvider>().updateDownloadTopic(key, '1');
  }

  bool checkNeedDownload() {
    if (_processItems.value == null) return false;

    if (_processAll.value == null) {
      updateTotalDownload();
      return totalNeedDownload > 0;
    } else {
      return (_processAll.value ?? 0) >= 100;
    }
  }

  void updateTotalDownload() {
    if (_processItems.value == null) return;
    totalNeedDownload = 0;
    _processItems.value?.values.forEach((fileInfo) {
      totalNeedDownload += fileInfo.status == DownloadStatus.COMPLETE ? 0 : 1;
    });
  }

  bool checkHasResource(String? link_resource) {
    FileInfo? fileInfo = processItems.value?[link_resource];
    return fileInfo == null || fileInfo.status == DownloadStatus.COMPLETE;
  }
}
