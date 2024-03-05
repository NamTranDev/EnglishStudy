import 'package:english_study/constants.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/setting_info.dart';
import 'package:english_study/model/topic_type.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/notification/notification_model.dart';
import 'package:english_study/screen/main/tab/setting/setting_tab_viewmodel.dart';
import 'package:english_study/screen/sync_data/sync_data_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  late SettingTabViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingTabViewModel>(
      builder: (context, viewmodel, _) {
        _viewModel = viewmodel;
        _viewModel.loading = (value) async {
          if (value is UpdateDataModel) {
            EasyLoading.dismiss();
            await Navigator.pushNamed(
                            context, SyncDataScreen.routeName,
                            arguments: value);
          } else {
            EasyLoading.show(
              // status: 'loading...',
              maskType: EasyLoadingMaskType.black,
            );
          }
        };
        return FutureBuilder(
            future: _viewModel.getSettingInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Something wrong with message: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                List<SettingInfo>? data = snapshot.data;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      SettingInfo? setting = data?.getOrNull(index);
                      if (setting == null) return SizedBox();
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(setting.name ?? '')),
                              ListenableBuilder(
                                listenable: setting,
                                builder: (context, widget) {
                                  return IgnorePointer(
                                    ignoring: setting.isEnable == false,
                                    child: buildSettingAction(setting),
                                  );
                                },
                              )
                            ],
                          ),
                          if (setting.any != null)
                            ListenableBuilder(
                              listenable: setting,
                              builder: (context, widget) {
                                return buildExpandWidget(setting);
                              },
                            )
                        ],
                      );
                    },
                    itemCount: data?.length,
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    );
  }

  buildSettingAction(SettingInfo setting) {
    switch (setting.id) {
      case 1:
      case 2:
        return Switch(
          value: setting.isToggle,
          onChanged: (value) {
            setting.isToggle = value;
            _viewModel.updateValue(setting);
            setting.notify();
          },
        );
      case 3:
        var isHasUpdate = setting.any as ValueNotifier<bool>;
        var radius = 10.0;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: () {
                _viewModel.checkNewData();
              },
              child: ValueListenableBuilder(
                valueListenable: isHasUpdate,
                builder: (context, value, _) {
                  return Container(
                    height: 50,
                    constraints: BoxConstraints(minWidth: 80),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        value ? 'Update' : 'Check Update',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: value ? turquoise : maastricht_blue),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      default:
        return SizedBox();
    }
  }

  buildExpandWidget(SettingInfo setting) {
    if (setting.isToggle) {
      switch (setting.any) {
        case NotificationModel:
          var notification = setting.any as NotificationModel;
          return GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now().replacing(
                      hour: notification.hour, minute: notification.minute),
                );
                if (picked == null) return;
                notification.hour = picked.hour;
                notification.minute = picked.minute;
                getIt<NotificationManager>()
                    .cancelNotification(notification.idNotification);
                getIt<Preference>().saveDailyNotification(notification);
                getIt<NotificationManager>()
                    .scheduleDailyNotification(notification);
                setting.notify();
              },
              child: Text(
                '${notification.hour}:${notification.minute}',
              ));
        default:
          return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }
}
