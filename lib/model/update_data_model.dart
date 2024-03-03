// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/model/update_link_info.dart';

class UpdateDataModel {
  int? version; // Đổi từ int sang int?
  List<UpdateLinkInfo>? urls; // Đổi từ List<String> sang List<String>?

  UpdateDataModel({required this.version, required this.urls});

  // Factory method để chuyển đổi từ Map sang đối tượng
  factory UpdateDataModel.fromJson(Map<String, dynamic> json) {
    return UpdateDataModel(
      version: json['version'],
      urls: (json['urls'] as List<dynamic>).map((urlData) {
        return UpdateLinkInfo.fromMap(urlData);
      }).toList(),
    );
  }

  @override
  String toString() => 'UpdateDataModel(version: $version, urls: $urls)';
}
