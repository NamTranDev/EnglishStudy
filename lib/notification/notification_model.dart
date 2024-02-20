import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationModel {
  int idNotification;
  int hour = 0;
  int minute = 0;
  bool isEnable = true;
  bool isSchedule = false;
  NotificationModel({
    required this.idNotification,
    required this.hour,
    required this.minute,
    required this.isEnable,
    required this.isSchedule,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idNotification': idNotification,
      'hour': hour,
      'minute': minute,
      'isEnable': isEnable,
      'isSchedule': isSchedule,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      idNotification: map['idNotification'] as int,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnable: map['isEnable'] as bool,
      isSchedule: map['isSchedule'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) => NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
