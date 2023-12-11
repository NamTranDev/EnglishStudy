import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:english_study/model/download_info.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  final Map<String?, DownloadInfo?> _downloadInfos = {};
  String? _currentCategory;

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
    final path = (await getTemporaryDirectory()).path;
    var directory =
        Directory("${getIt<AppMemory>().pathFolderDocument}/${category}");
    if (await directory.exists() == false) {
      await directory.create();
    }
    _initFileInfos(
        category,
        topics
            .map(
              (e) => FileInfo(e.link_resource, "${path}/${e.name}.zip",
                  directory.path, e.category,
                  status: e.isDownload == 1
                      ? DownloadStatus.COMPLETE
                      : DownloadStatus.NONE),
            )
            .toList());
    onNeedDownloadListener = (needDownload) {
      onSyncUI?.call(needDownload);
    };
  }

  void refresh(String? category) {
    var downloadInfo = _downloadInfos[category];
    if (downloadInfo == null) return;
    _currentCategory = category;
    _processAll.value = downloadInfo.processAll;
    var processCurrents = downloadInfo.processItems;

    if (processCurrents != null) {
      _processItems.value = Map.from(processCurrents);
    }
  }

  void _initFileInfos(String? category, List<FileInfo> fileInfos) {
    DownloadInfo? downloadInfo;
    _currentCategory = category;
    if (_downloadInfos.containsKey(category) == true) {
      downloadInfo = _downloadInfos[category];
    } else {
      var totalNeedDownload = 0;
      Map<String?, FileInfo>? processDownloads =
          fileInfos.fold({}, (map, fileInfo) {
        map?[fileInfo.link] = fileInfo;
        totalNeedDownload += fileInfo.status == DownloadStatus.NONE ? 1 : 0;
        return map;
      });
      downloadInfo = DownloadInfo(
          totalNeedDownload: totalNeedDownload,
          processAll: null,
          processItems: processDownloads);
      _downloadInfos[category] = downloadInfo;
    }
    if (downloadInfo != null) {
      _processAll.value = downloadInfo.processAll;
      var processCurrents = downloadInfo.processItems;

      if (processCurrents != null) {
        _processItems.value = Map.from(processCurrents);
      }
    }
  }

  Future<void> downloadAll() async {
    var downloadInfo = _downloadInfos[_currentCategory];
    if (downloadInfo == null) return;
    downloadInfo.processAll = 0.0;
    _processAll.value = 0.0;

    var processCurrents = downloadInfo.processItems;

    if (processCurrents != null) {
      processCurrents.forEach((key, file) {
        if (file.status == DownloadStatus.COMPLETE ||
            file.status == DownloadStatus.DOWNLOADING) return;
        _downloadFile(file);
      });
    }
  }

  Future<void> download(String? link) async {
    if (link == null) return;

    var downloadInfo = _downloadInfos[_currentCategory];
    if (downloadInfo == null) return;

    var processCurrents = downloadInfo.processItems;

    var fileInfoNeedDownload = processCurrents?[link];
    if (fileInfoNeedDownload != null &&
        fileInfoNeedDownload.status == DownloadStatus.NONE) {
      await _downloadFile(fileInfoNeedDownload);
    }
  }

  Future<void> _downloadFile(FileInfo fileInfo) async {
    var link = fileInfo.link;
    if (link == null) return;
    var downloadInfo = _downloadInfos[fileInfo.category];
    if (downloadInfo == null) return;
    fileInfo.status = DownloadStatus.DOWNLOADING;
    fileInfo.progress = 0;

    var processCurrents = downloadInfo.processItems;
    if (processCurrents != null && fileInfo.category == _currentCategory) {
      _processItems.value = Map.from(processCurrents);
    }

    final file = File(fileInfo.filePath);

    Dio dio = Dio();

    try {
      await dio.download(
        link,
        file.path,
        onReceiveProgress: (count, total) {
          var downloadInfo = _downloadInfos[fileInfo.category];
          if (downloadInfo == null) return;
          var processCurrents = downloadInfo.processItems;
          if (processCurrents != null) {
            var fileInfoCurrent = processCurrents[fileInfo.link];
            if (fileInfoCurrent != null) {
              var progress = (count / total) * 100;
              fileInfoCurrent.progress = progress / 2;
              if (_currentCategory == fileInfo.category) {
                _processItems.value = Map.from(processCurrents);
              }
              if (_processAll.value != null &&
                  downloadInfo.totalNeedDownload > 0 &&
                  _currentCategory == fileInfo.category) {
                updateProgressAll(fileInfo.category);
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
    var downloadInfo = _downloadInfos[fileInfo?.category];
    if (downloadInfo == null) return;
    var processCurrents = downloadInfo.processItems;
    if (processCurrents != null) {
      var fileInfoCurrent = processCurrents[fileInfo?.link];
      if (fileInfoCurrent != null) {
        fileInfoCurrent.status = DownloadStatus.NONE;
        fileInfoCurrent.progress = null;

        if (_currentCategory == fileInfo?.category) {
          _processItems.value = Map.from(processCurrents);
        }

        if (_processAll.value != null &&
            downloadInfo.totalNeedDownload > 0 &&
            _currentCategory == fileInfo?.category) {
          updateProgressAll(fileInfo?.category);
        }
      }
      onDownloadErrorListener?.call();
      var isHasDownload = processCurrents.values
              .where((element) => element.status == DownloadStatus.DOWNLOADING)
              .firstOrNull !=
          null;
      if (!isHasDownload) {
        downloadInfo.processAll = null;
        _processAll.value = null;
      }
    }
  }

  void updateProgressAll(String? category) {
    var downloadInfo = _downloadInfos[category];
    if (downloadInfo == null) return;
    var total = downloadInfo.processItems?.values
            .where((element) =>
                element.progress != null &&
                element.status == DownloadStatus.DOWNLOADING)
            .fold(0.0, (sum, item) => sum + (item.progress ?? 0)) ??
        0;
    var totalProcess = total / downloadInfo.totalNeedDownload;
    downloadInfo.processAll = totalProcess;
    _processAll.value = totalProcess;
  }

  Future<void> extractFile(FileInfo fileInfo, File file) async {
    var directory = Directory(fileInfo.folderPath);
    try {
      await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: directory,
        onExtracting: (zipEntry, progress) {
          var downloadInfo = _downloadInfos[fileInfo.category];
          if (downloadInfo != null) {
            var processCurrents = downloadInfo.processItems;
            if (processCurrents != null) {
              var fileInfoCurrent = processCurrents[fileInfo.link];
              if (fileInfoCurrent != null) {
                var progressValue = (100 + progress) / 2;
                fileInfoCurrent.progress = progressValue;
                if (_currentCategory == fileInfo.category) {
                  _processItems.value = Map.from(processCurrents);
                }

                if (_processAll.value != null &&
                    downloadInfo.totalNeedDownload > 0 &&
                    _currentCategory == fileInfo.category) {
                  updateProgressAll(fileInfo.category);
                }
              }
            }
          }
          return ZipFileOperation.includeItem;
        },
      );
      fileInfo.status = DownloadStatus.COMPLETE;
      updateTotalDownload(fileInfo.category);
      updateLengthDatabase(fileInfo.link);
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

  void updateTotalDownload(String? category) {
    var downloadInfo = _downloadInfos[category];
    if (downloadInfo == null) return;
    downloadInfo.totalNeedDownload = 0;
    downloadInfo.processItems?.values.forEach((fileInfo) {
      print(fileInfo);
      downloadInfo.totalNeedDownload +=
          fileInfo.status == DownloadStatus.COMPLETE ? 0 : 1;
    });
    print('Total Need Download : ' + downloadInfo.totalNeedDownload.toString());
    onNeedDownloadListener?.call(downloadInfo.totalNeedDownload > 0);
  }

  bool checkHasResource(String? link_resource) {
    var downloadInfo = _downloadInfos[_currentCategory];
    if (downloadInfo == null) return false;
    FileInfo? fileInfo = downloadInfo.processItems?[link_resource];
    return fileInfo == null || fileInfo.status == DownloadStatus.COMPLETE;
  }

  Map<String?, FileInfo>? hasProcessItems(String? category) {
    var downloadInfo = _downloadInfos[category];
    return downloadInfo?.processItems;
  }
}
