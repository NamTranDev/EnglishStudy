// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/download/file_info.dart';

class DownloadInfo {
  int totalNeedDownload = 0;
  double? processAll;
  Map<String?, FileInfo>? processItems;
  DownloadInfo({
    required this.totalNeedDownload,
    this.processAll,
    this.processItems,
  });
}
