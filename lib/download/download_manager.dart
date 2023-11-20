import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
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
    for (int i = 0; i < 100; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      _processAll.value = i + 1;

      var processCurrents = processItems.value;
      if (processCurrents != null) {
        processCurrents.forEach((key, value) {
          if (value.status == DownloadStatus.NONE) {
            value.status = DownloadStatus.DOWNLOADING;
          }
          value.progress = i + 1;
        });

        processItems.value = Map.from(processCurrents);
      }
    }
    _processAll.value = null;

    return;
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
    print(fileInfoNeedDownload);
    if (fileInfoNeedDownload != null &&
        fileInfoNeedDownload.status == DownloadStatus.NONE) {
      for (int i = 0; i < 100; i++) {
        await Future.delayed(Duration(milliseconds: 500));

        var processCurrents = processItems.value;
        if (processCurrents != null) {
          processCurrents.forEach((key, value) {
            if (key == fileInfoNeedDownload.link) {
              value.progress = i + 1;
              print(value.progress);
            }
          });

          processItems.value = Map.from(processCurrents);
        }
      }

      return;

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
        var processCurrents = processItems.value;
        if (processCurrents != null) {
          var fileInfoCurrent = processCurrents[fileInfo.link];
          if (fileInfoCurrent != null) {
            var progress = (count / total) * 100;
            fileInfoCurrent.progress = progress / 2;

            processItems.value = Map.from(processCurrents);
            if (processAll.value != null && totalNeedDownload > 0) {
              _processAll.value =
                  (_processAll.value! + progress) / (totalNeedDownload * 2);
            }
          }
        }
      },
    );
    await extractFile(fileInfo, file);
  }

  Future<void> extractFile(FileInfo fileInfo, File file) async {
    await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: Directory(fileInfo.folderPath),
        onExtracting: (zipEntry, progress) {
          var processCurrents = processItems.value;
          if (processCurrents != null) {
            var fileInfoCurrent = processCurrents[fileInfo.link];
            if (fileInfoCurrent != null) {
              var progressValue = (100 + progress) / 2;
              fileInfoCurrent.progress = progressValue;
              if (progress == 100) {
                fileInfoCurrent.status = DownloadStatus.COMPLETE;
              }
              processItems.value = Map.from(processCurrents);

              if (processAll.value != null && totalNeedDownload > 0) {
                processAll.value =
                    (processAll.value! + progress) / (totalNeedDownload * 2);
              }
            }
          }
          return ZipFileOperation.includeItem;
        });
  }

  bool checkAllDownload() {
    if (_processItems.value == null) return false;
    return _processItems.value?.values.firstWhere(
            (element) => element.status != DownloadStatus.COMPLETE) !=
        null;
  }
}
