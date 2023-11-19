import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/download/file_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';

class DownloadManager {
  String? _category;
  List<FileInfo>? _fileInfos;
  final ValueNotifier<double?> _processAll = ValueNotifier<double?>(null);
  ValueNotifier<double?> get processAll => _processAll;
  final ValueNotifier<Map<String?, double>?> _processItems =
      ValueNotifier<Map<String?, double>?>(null);
  ValueNotifier<Map<String?, double>?> get processItems => _processItems;

  void initFileInfos(String category, List<FileInfo> fileInfos) {
    if (_category == category) {
      return;
    }
    _category = category;
    this._fileInfos = fileInfos;
  }

  Future<void> downloadAll() async {
    if (_fileInfos == null) {
      return;
    }
    for (int i = 0; i < 100; i++) {
      await Future.delayed(Duration(milliseconds: 500));
      _processAll.value = i + 1;
    }
    _processAll.value = null;

    return;
    _processAll.value = 0.0;
    for (var file in _fileInfos!) {
      if (file.status == DownloadStatus.COMPLETE ||
          file.status == DownloadStatus.DOWNLOADING) continue;
      _downloadFile(file);
    }
  }

  void download(String link) {
    if (_fileInfos == null) {
      return;
    }
    var fileInfoNeedDownload =
        _fileInfos?.firstWhere((element) => element.link == link, orElse: null);
    if (fileInfoNeedDownload != null &&
        fileInfoNeedDownload.status == DownloadStatus.NONE) {
      _downloadFile(fileInfoNeedDownload);
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
        var processCurrent = processItems.value;
        processCurrent?[fileInfo.link] = (count / total) * 100;
        if (processAll != null) {}
      },
    );
    await extractFile(fileInfo, file);
  }

  Future<void> extractFile(FileInfo fileInfo, File file) async {
    await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: Directory(fileInfo.folderPath),
        onExtracting: (zipEntry, progress) {
          fileInfo.progress = progress;

          return ZipFileOperation.includeItem;
        });
    fileInfo.status = DownloadStatus.COMPLETE;
  }
}
