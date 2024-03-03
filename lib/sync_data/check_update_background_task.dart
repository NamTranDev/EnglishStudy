import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';

Future<void> checkDataBackgroundTask() async {
  final ReceivePort receivePort = ReceivePort();
  final isolate = await Isolate.spawn(backgroundTask, [
    receivePort.sendPort,
    getIt<Preference>(),
  ]);

  receivePort.listen((dynamic data) {
    logger(data);
    receivePort.close();
    isolate.kill();
    getIt<AppMemory>().isHasUpdate.value = data;
  });
}

void backgroundTask(List<dynamic> arguments) async {
  SendPort sendPort = arguments[0];
  Preference pref = arguments[1];

  var updateVersion = await getUpdateVersion();
  var currentVersion = pref.versionUpdate();
  logger(currentVersion);
  if (currentVersion < (updateVersion?.version ?? 0)) {
    sendPort.send(true);
  }

  sendPort.send(false);
}

Future<UpdateDataModel?> getUpdateVersion() async {
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
      return data;
    }
  } on DioError catch (e) {
    logger(e);
  }
  return null;
}
