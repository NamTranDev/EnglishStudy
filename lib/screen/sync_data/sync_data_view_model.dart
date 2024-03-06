import 'package:english_study/constants.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/model/update_response.dart';
import 'package:english_study/sync_data/update_background_task.dart';
import 'package:flutter/cupertino.dart';

class SyncDataViewModel {
  final ValueNotifier<UpdateReponse?> _updateValue =
      ValueNotifier<UpdateReponse?>(null);
  ValueNotifier<UpdateReponse?> get updateValue => _updateValue;

  Future<void> runSync(UpdateDataModel? argument) async {
    await Future.delayed(
        const Duration(milliseconds: 2 * duration_animation_screen));

    getDataBackgroundTask(argument, (status) {
      // logger(status);
      
      _updateValue.value = status;
    });
  }
}
