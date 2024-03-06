// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UpdateLinkInfo {
  String? key;
  String? url;
  String? url_resource;
  UpdateLinkInfo({
    this.key,
    this.url,
    this.url_resource,
  });

  factory UpdateLinkInfo.fromMap(Map<String, dynamic> map) {
    return UpdateLinkInfo(
      key: map['key'] != null ? map['key'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      url_resource: map['url_resource'] != null ? map['url_resource'] as String : null,
    );
  }

  factory UpdateLinkInfo.fromJson(String source) => UpdateLinkInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UpdateLinkInfo(name: $key, url: $url,url_resource : $url_resource)';
}
