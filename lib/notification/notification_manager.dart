// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:english_study/localization/generated/l10n.dart';
import 'package:english_study/notification/notification_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:english_study/notification/received_notification.dart';

Future<NotificationManager> initMotification() async {
  NotificationManager notificationManager = NotificationManager._();
  await notificationManager._initialize();
  return notificationManager;
}

class NotificationManager {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AndroidInitializationSettings initializationSettingsAndroid;
  late DarwinInitializationSettings initializationSettingsDarwin;
  late InitializationSettings initializationSettings;

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  /// A notification action which triggers a App navigation event
  String navigationActionId = 'id_3';

  NotificationManager._() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    _configureLocalTimeZone();
  }

  Future<void> _initialize() async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    didReceiveLocalNotificationStream.add(
      ReceivedNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        selectNotificationStream.add(notificationResponse.payload);
        break;
      case NotificationResponseType.selectedNotificationAction:
        if (notificationResponse.actionId == navigationActionId) {
          selectNotificationStream.add(notificationResponse.payload);
        }
        break;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // -------------------------------------------- init state ------------------------------------------------------

  Future<void> isAndroidPermissionGranted(Function refresh) async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> requestPermissions(Function refresh) async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestPermission();
      refresh.call();
    }
  }

  void configureDidReceiveLocalNotificationSubject(BuildContext context) {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                print("DidReceiveLocalNotificationSubject");
                // Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.of(context).push(
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) =>
                //         (receivedNotification.payload),
                //   ),
                // );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      print('SelectNotificationSubject');
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => SecondPage(payload),
      // ));
    });
  }

  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
  }

  // ----------------------------------------------------------------------------------------------------------------

  Future<void> scheduleDailyNotification(NotificationModel model) async {
    if (model.isEnable == false) return;
    if (model.isSchedule == true) return;
    model.isSchedule = true;

    //test
    // await flutterLocalNotificationsPlugin.periodicallyShow(
    //     model.idNotification,
    //     'English Study Daily Notification',
    //     'Open app to learn',
    //     RepeatInterval.everyMinute,
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails('daily notification channel id',
    //           'daily notification channel name',
    //           channelDescription: 'daily notification description'),
    //     ));

    // return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, model.hour, model.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    getIt<Preference>().saveDailyNotification(model);
    var localize = getIt<Localize>();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        model.idNotification,
        localize.notification_title_daily,
        localize.notification_body_daily,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTime() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(seconds: 30));
    }
    return scheduledDate;
  }

  Future<void> _scheduleWeeklyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfTime(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleWeeklyDayNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'weekly scheduled notification title',
        'weekly scheduled notification body',
        _nextInstanceOfDay(),
        const NotificationDetails(
          android: AndroidNotificationDetails('weekly notification channel id',
              'weekly notification channel name',
              channelDescription: 'weekly notificationdescription'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  Future<void> _scheduleMonthlyDayNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'monthly scheduled notification title',
        'monthly scheduled notification body',
        _nextInstanceOfDay(),
        const NotificationDetails(
          android: AndroidNotificationDetails('monthly notification channel id',
              'monthly notification channel name',
              channelDescription: 'monthly notificationdescription'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfDay() {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime();
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
