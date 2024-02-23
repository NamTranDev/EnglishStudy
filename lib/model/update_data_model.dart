// ignore_for_file: public_member_api_docs, sort_constructors_first
class UpdateDataModel {
  int? version; // Đổi từ int sang int?
  List<String>? urls; // Đổi từ List<String> sang List<String>?

  UpdateDataModel({required this.version, required this.urls});

  // Factory method để chuyển đổi từ Map sang đối tượng
  factory UpdateDataModel.fromJson(Map<String, dynamic> json) {
    return UpdateDataModel(
      version: json['version'],
      urls: List<String>.from(json['URLs'] ?? []),
    );
  }

  @override
  String toString() => 'UpdateDataModel(version: $version, urls: $urls)';
}
