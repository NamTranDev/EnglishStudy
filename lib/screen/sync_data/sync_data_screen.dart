import 'package:english_study/constants.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/model/update_response.dart';
import 'package:english_study/model/update_status.dart';
import 'package:english_study/restart_app.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/screen/sync_data/sync_data_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class SyncDataScreen extends StatelessWidget {
  static String routeName = '/sync_data';
  const SyncDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var argument =
        ModalRoute.of(context)?.settings.arguments as UpdateDataModel?;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Provider.value(
            value: SyncDataViewModel(),
            child: Consumer<SyncDataViewModel>(
                builder: (context, viewmodel, child) {
              viewmodel.runSync(argument);
              return Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(20),
                child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: viewmodel.updateValue,
                      builder: (context, value, widget) {
                        if (value?.status == UpdateStatus.COMPLETE) {
                          return buildComplete(context);
                        }
                        if (value?.status == UpdateStatus.ERROR) {
                          SchedulerBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  actionsAlignment: MainAxisAlignment.center,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Error',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Đã xãy ra lỗi trong quá trình cập nhật dữ liệu',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        }
                        return value != null &&
                                value.status == UpdateStatus.UPDATE
                            ? buildSyncData(context, value)
                            : const Center(
                                child: CircularProgressIndicator(),
                              );
                      }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  buildComplete(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Update Complete',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () {
            RestartWidget.restartApp(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: maastricht_blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          child: Text(
            "Restart App",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  buildSyncData(BuildContext context, UpdateReponse value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.category?.title ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          value.topic?.name ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(
          height: 10,
        ),
        LinearProgressIndicator(
          value: value.process,
        ),
      ],
    );
  }
}
