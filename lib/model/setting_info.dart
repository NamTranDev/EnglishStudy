// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

class SettingInfo with ChangeNotifier {
  int id;
  String? name;
  bool isEnable = true;
  bool isToggle = false;
  SettingInfo({
    required this.id,
    this.name,
    required this.isEnable,
    required this.isToggle,
  });

  void notify() {
    notifyListeners();
  }
}
