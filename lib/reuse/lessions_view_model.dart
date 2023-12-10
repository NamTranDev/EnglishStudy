import 'package:english_study/download/download_manager.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:flutter/material.dart';

abstract class LessionsViewModel {
  final ValueNotifier<int> _updateLessionStatus = ValueNotifier<int>(0);
  ValueNotifier<int> get updateLessionStatus => _updateLessionStatus;

  final DownloadManager _downloadManager = getIt<DownloadManager>();
  DownloadManager get downloadManager => _downloadManager;

  Future<bool> syncLession(String? id);

  void updateStatus(){
    _updateLessionStatus.value = _updateLessionStatus.value++;
  }
}
