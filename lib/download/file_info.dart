import 'package:english_study/download/download_status.dart';

class FileInfo {
  final String? link;
  final String filePath;
  final String folderPath;
  final String? category;
  double? progress;
  DownloadStatus status;

  FileInfo(
    this.link,
    this.filePath,
    this.folderPath, this.category, {
    this.progress,
    this.status = DownloadStatus.NONE,
  });
}
