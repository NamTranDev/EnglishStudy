import 'dart:async';

import 'package:english_study/constants.dart';
import 'package:english_study/localization/generated/l10n.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/restart_app.dart';
import 'package:english_study/screen/splash/splash_screen.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'package:english_study/navigator.dart' as nav;
import 'package:english_study/services/service_locator.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _deleteCacheDir();

  await setupServiceLocator();

  scheduleNotification();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(RestartWidget(child: const MyApp()));
}

void scheduleNotification() {
  var notification = getIt<NotificationManager>();
  notification
      .scheduleDailyNotification(getIt<Preference>().dailyNotification());
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

  static void setLocale(BuildContext context, Locale newLocale) {}
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = Locale(getIt<Preference>().languageLocalize());

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    return MaterialApp(
      theme: themeInfo,
      localizationsDelegates: const [
        Localize.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: Localize.delegate.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (supportedLocales
            .map((e) => e.languageCode)
            .contains(deviceLocale?.languageCode)) {
          return deviceLocale;
        } else {
          return const Locale('en', '');
        }
      },
      locale: _locale,
      initialRoute: SplashScreen.routeName,
      routes: nav.routes,
      builder: EasyLoading.init(),
    );
  }

  @override
  void initState() {
    super.initState();
    getIt<NotificationManager>().isAndroidPermissionGranted(() {
      // setState(() {});
      scheduleNotification();
    });
    getIt<NotificationManager>().requestPermissions(() {
      // setState(() {});
      scheduleNotification();
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
