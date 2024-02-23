import 'dart:convert';

class Category {
  String? key;
  String? title;
  String? description;
  Category({
    this.key,
    this.title,
    this.description,
  });

  Category copyWith({
    String? key,
    String? title,
    String? description,
  }) {
    return Category(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'key': key,
      'title': title,
      'description': description,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      key: map['key'] != null ? map['key'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Category(key: $key, title: $title, description: $description)';

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;
  
    return 
      other.key == key &&
      other.title == title &&
      other.description == description;
  }

  @override
  int get hashCode => key.hashCode ^ title.hashCode ^ description.hashCode;
}
