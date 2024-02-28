import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> checkDataBackgroundTask() async {
  final ReceivePort receivePort = ReceivePort();
  final isolate = await Isolate.spawn(backgroundTask,
      [receivePort.sendPort, getIt<Preference>(), getIt<AppMemory>()]);

  receivePort.listen((dynamic data) {
    logger(data);
    receivePort.close();
    isolate.kill();
  });
}

void backgroundTask(List<dynamic> arguments) async {
  SendPort sendPort = arguments[0];
  Preference pref = arguments[1];
  AppMemory appMemory = arguments[2];

  Dio dio = Dio();

  try {
    Response response = await dio.get(
      URL_UPDATE,
      options: Options(
        contentType: 'application/json;charset=UTF-8',
        responseType: ResponseType.plain,
      ),
    );
    logger(response.statusCode);
    if (response.statusCode == 200) {
      logger(response.data);
      var data = UpdateDataModel.fromJson(jsonDecode(response.data));
      logger(data);
      var currentVersion = pref.versionUpdate();
      if (currentVersion < (data.version ?? 0)) {
        appMemory.isHasUpdate = true;
      }
    }
  } on DioError catch (e) {
    logger(e);
  }

  sendPort.send('Background task completed.');
}
