import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  String? _category;
  int totalNeedDownload = 0;
  final ValueNotifier<double?> _processAll = ValueNotifier<double?>(null);
  ValueNotifier<double?> get processAll => _processAll;
  final ValueNotifier<Map<String?, FileInfo>?> _processItems =
      ValueNotifier<Map<String?, FileInfo>?>(null);
  ValueNotifier<Map<String?, FileInfo>?> get processItems => _processItems;

  Function? onNeedDownloadListener;
  Function? onDownloadErrorListener;

  Future<void> checkNeedDownload(String? category, List<Topic>? topics,
      {Function? onSyncUI}) async {
    if (topics == null) return;
    var isNeedDownload =
        topics.where((element) => element.isDownload == 0).firstOrNull != null;
    onSyncUI?.call(isNeedDownload);
    if (isNeedDownload) {
      final path = (await getTemporaryDirectory()).path;
      var directory =
          Directory("${getIt<AppMemory>().pathFolderDocument}/${category}");
      if (await directory.exists() == false) {
        await directory.create();
      }
      initFileInfos(
          category,
          topics
              .map(
                (e) => FileInfo(
                    e.link_resource, "${path}/${e.name}.zip", directory.path,
                    status: e.isDownload == 1
                        ? DownloadStatus.COMPLETE
                        : DownloadStatus.NONE),
              )
              .toList());
      onNeedDownloadListener = (needDownload) {
        onSyncUI?.call(needDownload);
      };
    }
  }

  void initFileInfos(String? category, List<FileInfo> fileInfos) {
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
    fileInfo.progress = 0;
    var processCurrents = processItems.value;
    if (processCurrents != null) {
      processItems.value = Map.from(processCurrents);
    }

    final file = File(fileInfo.filePath);

    Dio dio = Dio();

    try {
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
                updateProgressAll();
              }
            }
          }
        },
      );
      await extractFile(fileInfo, file);
    } on DioError catch (e) {
      print(e);
      updateItemDownloadError(fileInfo);
    }
  }

  void updateItemDownloadError(FileInfo? fileInfo) {
    var processCurrents = processItems.value;
    if (processCurrents != null) {
      var fileInfoCurrent = processCurrents[fileInfo?.link];
      if (fileInfoCurrent != null) {
        fileInfoCurrent.status = DownloadStatus.NONE;
        fileInfoCurrent.progress = null;

        processItems.value = Map.from(processCurrents);
        if (processAll.value != null && totalNeedDownload > 0) {
          updateProgressAll();
        }
      }
      onDownloadErrorListener?.call();
      var isHasDownload = processCurrents.values
              .where((element) => element.status == DownloadStatus.DOWNLOADING)
              .firstOrNull !=
          null;
      if (!isHasDownload) {
        _processAll.value = null;
      }
    }
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
    var directory = Directory(fileInfo.folderPath);
    try {
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
      print('size : $size');
    } catch (e) {
      print(e);
      directory.deleteSync();
      updateItemDownloadError(fileInfo);
    }
    file.delete();
  }

  void updateLengthDatabase(String? key) async {
    getIt<DBProvider>().updateDownloadTopic(key, '1');
  }

  void updateTotalDownload() {
    if (_processItems.value == null) return;
    totalNeedDownload = 0;
    _processItems.value?.values.forEach((fileInfo) {
      totalNeedDownload += fileInfo.status == DownloadStatus.COMPLETE ? 0 : 1;
    });

    onNeedDownloadListener?.call(totalNeedDownload > 0);
  }

  bool checkHasResource(String? link_resource) {
    FileInfo? fileInfo = processItems.value?[link_resource];
    return fileInfo == null || fileInfo.status == DownloadStatus.COMPLETE;
  }
}
