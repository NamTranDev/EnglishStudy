import 'package:english_study/logger.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/model/update_response.dart';
import 'package:english_study/sync_data/update_background_task.dart';
import 'package:flutter/cupertino.dart';

class SyncDataViewModel {
  final ValueNotifier<UpdateReponse?> _updateValue =
      ValueNotifier<UpdateReponse?>(null);
  ValueNotifier<UpdateReponse?> get updateValue => _updateValue;

  runSync(UpdateDataModel? argument) {
    getDataBackgroundTask(argument, (status) {
      logger(status);
      _updateValue.value = status;
    });
  }
}
