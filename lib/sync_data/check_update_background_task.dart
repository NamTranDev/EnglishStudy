import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/update_data_model.dart';

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
  } catch (e) {
    logger(e);
  }
  return null;
}
