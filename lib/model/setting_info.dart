// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_study/notification/notification_model.dart';
import 'package:flutter/cupertino.dart';

class SettingInfo with ChangeNotifier {
  int id;
  String? name;
  bool isEnable = true;
  bool isToggle = false;
  Object? any;
  SettingInfo({
    required this.id,
    this.name,
    required this.isEnable,
    required this.isToggle,
    this.any
  });

  void notify() {
    notifyListeners();
  }
}
