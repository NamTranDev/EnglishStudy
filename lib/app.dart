import 'dart:async';
import 'dart:io';

import 'package:english_study/constants.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:english_study/navigator.dart' as nav;
import 'package:english_study/services/service_locator.dart';

Future main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  var notification = getIt<NotificationManager>();
  notification.scheduleDailyNotification(getIt<Preference>().dailyNotification());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    return MaterialApp(
      theme: themeInfo,
      initialRoute: MainScreen.routeName,
      routes: nav.routes,
    );
  }

  @override
  void initState() {
    super.initState();
    getIt<NotificationManager>().isAndroidPermissionGranted(() {
      setState(() {});
    });
    getIt<NotificationManager>().requestPermissions(() {
      setState(() {});
    });
    getIt<NotificationManager>()
        .configureDidReceiveLocalNotificationSubject(context);
    getIt<NotificationManager>().configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    getIt<NotificationManager>().dispose();
    super.dispose();
  }
}
