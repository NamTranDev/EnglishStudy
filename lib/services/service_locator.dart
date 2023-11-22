import 'package:english_study/download/download_manager.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<DBProvider>(await initDBProvider());
  getIt.registerSingleton<Preference>(await initPreference());
  getIt.registerSingleton<AppMemory>(await initMemory());
  getIt.registerSingleton<DownloadManager>(DownloadManager());
}
