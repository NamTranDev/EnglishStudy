import 'package:english_study/download/download_manager.dart';
import 'package:english_study/model/setting_info.dart';
import 'package:english_study/model/tab_type.dart';
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
                return ListTile(
                  title: Text(setting.name ?? ''),
                  trailing: ListenableBuilder(
                    listenable: setting,
                    builder: (context, widget) {
                      return IgnorePointer(
                        ignoring: setting.isEnable == false,
                        child: Switch(
                          value: setting.isToggle,
                          onChanged: (value) {
                            setting.isToggle = value;
                            setting.notify();
                            switch (setting.id) {
                              case 1:
                                getIt<Preference>()
                                    .setConversationBackground(value);
                                break;
                            }
                          },
                        ),
                      );
                    },
                  ),
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

  Future<List<SettingInfo>> getSettingInfo() async {
    var category = getIt<Preference>().currentCategory(TabType.LISTEN.value);
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
    return Future.value([
      SettingInfo(
          id: 1,
          name: 'Enable Background Conversation',
          isEnable: isEnable,
          isToggle: getIt<Preference>().isConversationBackground()),
    ]);
  }
}
