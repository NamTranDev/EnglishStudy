import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/setting_info.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/notification/notification_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSettingInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  "Something wrong with message: ${snapshot.error.toString()}"),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            List<SettingInfo>? data = snapshot.data;
            return ListView.builder(
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
                              child: Switch(
                                value: setting.isToggle,
                                onChanged: (value) {
                                  setting.isToggle = value;
                                  switch (setting.id) {
                                    case 1:
                                      getIt<Preference>()
                                          .setConversationBackground(value);
                                      break;
                                    case 2:
                                      var notification =
                                          setting.notificationDaily;
                                      if (notification != null) {
                                        notification.isEnable = value;
                                        getIt<Preference>()
                                            .saveDailyNotification(
                                                notification);
                                        if (value == false) {
                                          getIt<NotificationManager>()
                                              .cancelNotification(
                                                  notification.idNotification);
                                        } else {
                                          getIt<NotificationManager>()
                                              .scheduleDailyNotification(
                                                  notification);
                                        }
                                      }
                                      break;
                                  }
                                  setting.notify();
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
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
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  buildExpandWidget(SettingInfo setting) {
    if (setting.isToggle) {
      switch (setting.id) {
        case 2:
          return GestureDetector(
              onTap: () async {
                var notification = setting.notificationDaily;
                if (notification == null) return;

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
                '${setting.notificationDaily?.hour}:${setting.notificationDaily?.minute}',
              ));
        default:
          return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  Future<List<SettingInfo>> getSettingInfo() async {
    var iPref = getIt<Preference>();
    var category = iPref.currentCategory(TabType.LISTEN.value);
    bool isEnable = true;
    if (category == null) {
      isEnable = false;
    } else {
      var topics = await getIt<DBProvider>().getTopics(
        category,
        TabType.LISTEN.value,
      );
      isEnable =
          (await getIt<DownloadManager>().isNeedDownload(category, topics)) ==
              false;
    }
    List<SettingInfo> settings = [];
    settings.add(SettingInfo(
        id: 1,
        name: 'Enable Background Conversation',
        isEnable: isEnable,
        isToggle: getIt<Preference>().isConversationBackground()));
    NotificationModel notification = iPref.dailyNotification();
    settings.add(SettingInfo(
        id: 2,
        name: 'Enable Notification Daily',
        isEnable: true,
        isToggle: notification.isEnable,
        notificationDaily: notification));
    return Future.value(settings);
  }
}
