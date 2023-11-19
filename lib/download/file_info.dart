import 'package:english_study/download/download_status.dart';

class FileInfo {
  final String? link;
  final String filePath;
  final String folderPath;
  double progress;
  DownloadStatus status;

  FileInfo(
    this.link,
    this.filePath,
    this.folderPath, {
    this.progress = 0.0,
    this.status = DownloadStatus.NONE,
  });
}
