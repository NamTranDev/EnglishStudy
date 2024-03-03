// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UpdateLinkInfo {
  String? name;
  String? url;
  UpdateLinkInfo({
    this.name,
    this.url,
  });

  factory UpdateLinkInfo.fromMap(Map<String, dynamic> map) {
    return UpdateLinkInfo(
      name: map['name'] != null ? map['name'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
    );
  }

  factory UpdateLinkInfo.fromJson(String source) => UpdateLinkInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UpdateLinkInfo(name: $name, url: $url)';
}
