import 'package:audio_service/audio_service.dart';
import 'package:english_study/audio/audio_handler.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<DownloadManager>(DownloadManager());
  getIt.registerSingleton<DBProvider>(await initDBProvider(
      (await getApplicationDocumentsDirectory()).path,
      await rootBundle.load('assets/english.db')));
  getIt.registerSingleton<Preference>(await initPreference());
  getIt.registerSingleton<AppMemory>(await initMemory());
  getIt.registerSingleton<NotificationManager>(await initMotification());
  getIt.registerSingleton<AudioHandler>(await initAudioService());
}
