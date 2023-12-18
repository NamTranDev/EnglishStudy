import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';

void nextPickCategory(BuildContext context, Topic? topic) {
  getIt<DBProvider>().syncTopicComplete(topic?.id?.toString());
  getIt<Preference>().setCurrentCategory(topic?.type, null);
  getIt<AppMemory>().currentTab = topic?.type;
  Navigator.pushNamedAndRemoveUntil(
      context, MainScreen.routeName, (route) => false);
}
