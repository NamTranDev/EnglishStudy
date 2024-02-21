import 'dart:io';
import 'dart:isolate';

import 'package:english_study/logger.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> syncDataBackgroundTask() async {
  final ReceivePort receivePort = ReceivePort();
  final isolate = await Isolate.spawn(backgroundTask, [
    receivePort.sendPort,
    (await getApplicationDocumentsDirectory()).path,
    await rootBundle.load('assets/english.db')
  ]);

  receivePort.listen((dynamic data) {
    logger(data);
    receivePort.close();
    isolate.kill();
  });
}

void backgroundTask(List<dynamic> arguments) async {
  SendPort sendPort = arguments[0];
  String folderPath = arguments[1];
  ByteData assetByte = arguments[2];

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  DBProvider db = await initDBProvider(folderPath, assetByte);
  logger(db);
  logger(db.getDatabase());
  for (int i = 0; i < 1000; i++) {
    print(await db.getVocabulary(i.toString()));
  }
  sendPort.send('Background task completed.');
}
