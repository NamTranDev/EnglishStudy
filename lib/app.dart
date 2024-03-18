import 'dart:async';
import 'dart:io';

import 'package:english_study/constants.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/restart_app.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:english_study/navigator.dart' as nav;
import 'package:english_study/services/service_locator.dart';

Future main() async {
  databaseFactoryOrNull = null;
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();

  _deleteCacheDir();

  await setupServiceLocator();

  var notification = getIt<NotificationManager>();
  notification
      .scheduleDailyNotification(getIt<Preference>().dailyNotification());

  runApp(RestartWidget(child: const MyApp()));
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
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
      initialRoute: SplashScreen.routeName,
      routes: nav.routes,
      builder: EasyLoading.init(),
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
