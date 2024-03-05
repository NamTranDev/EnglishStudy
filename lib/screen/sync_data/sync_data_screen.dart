import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/model/update_response.dart';
import 'package:english_study/model/update_status.dart';
import 'package:english_study/screen/sync_data/sync_data_view_model.dart';

import 'package:flutter/material.dart';
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
                padding: EdgeInsets.all(20),
                child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: viewmodel.updateValue,
                      builder: (context, value, widget) {
                        return value != null &&
                                value.status == UpdateStatus.UPDATE
                            ? buildSyncData(context, value)
                            : const Center(
                                child: CircularProgressIndicator(),
                              );
                      }),
                ),
              );
              ;
            }),
          ),
        ),
      ),
    );
  }

  buildSyncData(BuildContext context, UpdateReponse value) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          value.category?.title ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 30,),
        // Text(
        //   value.category?.description ?? '',
        //   style: Theme.of(context).textTheme.bodySmall,
        // ),
        Text(
          value.topic?.name ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 10,),
        LinearProgressIndicator(
          value: value.process,
        ),
      ],
    );
  }
}
