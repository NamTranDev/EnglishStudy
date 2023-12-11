// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  String toString() {
    return 'FileInfo(link: $link, filePath: $filePath, folderPath: $folderPath, category: $category, progress: $progress, status: $status)';
  }
}
