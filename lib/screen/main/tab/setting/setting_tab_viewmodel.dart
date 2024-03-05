import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/download/download_manager.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/category.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/setting_info.dart';
import 'package:english_study/model/spelling.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic_type.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/transcript.dart';
import 'package:english_study/model/update_link_info.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/notification/notification_manager.dart';
import 'package:english_study/notification/notification_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/sync_data/check_update_background_task.dart';
import 'package:english_study/sync_data/update_background_task.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';

class SettingTabViewModel with ChangeNotifier {
  Function? loading;

  Future<List<SettingInfo>> getSettingInfo() async {
    var iPref = getIt<Preference>();
    var category = iPref.currentCategory(TopicType.LISTEN.value);
    bool isEnable = true;
    if (category == null) {
      isEnable = false;
    } else {
      var topics = await getIt<DBProvider>().getTopics(
        category,
        TopicType.LISTEN.value,
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
        any: notification));
    settings.add(
      SettingInfo(
          id: 3,
          name: 'Check Update Data',
          isEnable: true,
          isToggle: true,
          any: getIt<AppMemory>().isHasUpdate),
    );
    return Future.value(settings);
  }

  void updateValue(SettingInfo setting) {
    switch (setting.id) {
      case 1:
        getIt<Preference>().setConversationBackground(setting.isToggle);
        break;
      case 2:
        var notification = setting.any as NotificationModel?;
        if (notification != null) {
          notification.isEnable = setting.isToggle;
          getIt<Preference>().saveDailyNotification(notification);
          if (setting.isToggle == false) {
            getIt<NotificationManager>()
                .cancelNotification(notification.idNotification);
          } else {
            getIt<NotificationManager>()
                .scheduleDailyNotification(notification);
          }
        }
        break;
    }
  }

  Future<void> checkNewData() async {
    loading?.call(true);
    var updateData = await getUpdateVersion();
    loading?.call(updateData);
  }
}
