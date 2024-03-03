import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';

class UpdateRequest {
  final SendPort sendPort;
  final RootIsolateToken token;
  final String pathFolder;
  final Preference iPref;
  final String folderPath;
  final ByteData assetByte;
  final UpdateDataModel? updateVersion;

  UpdateRequest(
      {required this.sendPort,
      required this.token,
      required this.pathFolder,
      required this.iPref,
      required this.folderPath,
      required this.assetByte,
      required this.updateVersion});
}
