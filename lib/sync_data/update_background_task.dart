import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/category.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/spelling.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic_type.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/transcript.dart';
import 'package:english_study/model/update_data_model.dart';
import 'package:english_study/model/update_link_info.dart';
import 'package:english_study/model/update_request.dart';
import 'package:english_study/model/update_response.dart';
import 'package:english_study/model/update_status.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/foundation.dart' as isolate;
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> getDataBackgroundTask(
    UpdateDataModel? updateVersion, Function? onStatus) async {
  final ReceivePort receivePort = ReceivePort();
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

  final isolate = await Isolate.spawn(
      backgroundTask,
      UpdateRequest(
        sendPort: receivePort.sendPort,
        token: rootIsolateToken,
        pathFolder: (await getTemporaryDirectory()).path,
        iPref: getIt<Preference>(),
        folderPath: (await getApplicationDocumentsDirectory()).path,
        assetByte: await rootBundle.load('assets/english.db'),
        updateVersion: updateVersion,
      ));

  receivePort.listen((dynamic data) {
    // logger(data);
    if (data is UpdateReponse) {
      onStatus?.call(data);
      if (data.status == UpdateStatus.COMPLETE) {
        receivePort.close();
        isolate.kill();
      }
    } else if (data is int) {
      getIt<Preference>().saveVersionUpdate(data);
    }
  });
}

void backgroundTask(UpdateRequest request) async {
  SendPort sendPort = request.sendPort;
  String path = request.pathFolder;
  Preference pref = request.iPref;

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  DBProvider db = await initDBProvider(request.folderPath, request.assetByte);

  UpdateDataModel? updateVersion = request.updateVersion;

  BackgroundIsolateBinaryMessenger.ensureInitialized(request.token);

  var currentVersionApp = pref.versionUpdate();
  var currentVersion = (updateVersion?.version ?? 0);
  if (currentVersionApp < currentVersion) {
    for (int i = currentVersionApp; i < currentVersion; i++) {
      sendPort.send(UpdateReponse(UpdateStatus.LOADING));
      try {
        UpdateLinkInfo? updateLink = updateVersion?.urls?.getOrNull(i);
        if (updateLink == null || updateLink.url == null) {
          continue;
        }
        var pathStore = "${path}/${updateLink.name}.zip";
        final fileDownload = File(pathStore);
        Dio dio = Dio();
        await dio.download(updateLink.url!, pathStore);

        var directory = Directory("${path}");
        if (await directory.exists() == false) {
          await directory.create();
        }

        await ZipFile.extractToDirectory(
          zipFile: fileDownload,
          destinationDir: directory,
        );
        var folder = Directory("${path}/${updateLink.name}");
        var folderExist = folder.existsSync();
        logger(folderExist);
        if (folderExist) {
          List<FileSystemEntity>? files = folder.listSync();

          FileSystemEntity? categoryFile =
              getFileByName(files, 'category.json');
          if (categoryFile != null) {
            List<Category> categories = await loadItemsFromFile<Category>(
                categoryFile.path, (json) => Category.fromMap(json));
            Category? category = categories.getOrNull(0);

            if (category != null) {
              var isExist = await db.checkCategoryExist(category.key);
              logger(isExist);
              if (isExist == false) {
                List<Topic>? topics;
                List<SubTopic>? subTopics;
                List<Conversation>? conversations;
                List<Vocabulary>? vocabularies;
                List<Transcript>? transcripts;
                List<Audio>? audios;
                List<Audio>? audio_conversations;
                List<Spelling>? spellings;
                List<Example>? examples;
                for (var file in files) {
                  if (file is File) {
                    // logger(file.path);
                    if (file.path.endsWith('sub_topics.json')) {
                      subTopics = await loadItemsFromFile<SubTopic>(
                          file.path, (json) => SubTopic.fromMap(json));
                    } else if (file.path.endsWith('topics.json')) {
                      topics = await loadItemsFromFile<Topic>(
                          file.path, (json) => Topic.fromMap(json));
                    } else if (file.path.endsWith('audio_conversation.json')) {
                      audio_conversations = await loadItemsFromFile<Audio>(
                          file.path, (json) => Audio.fromMap(json, true));
                    } else if (file.path.endsWith('conversation.json')) {
                      conversations = await loadItemsFromFile<Conversation>(
                          file.path, (json) => Conversation.fromMap(json));
                    } else if (file.path.endsWith('vocabulary.json')) {
                      vocabularies = await loadItemsFromFile<Vocabulary>(
                          file.path, (json) => Vocabulary.fromMap(json));
                    } else if (file.path.endsWith('transcript.json')) {
                      transcripts = await loadItemsFromFile<Transcript>(
                          file.path, (json) => Transcript.fromMap(json));
                    } else if (file.path.endsWith('audio.json')) {
                      audios = await loadItemsFromFile<Audio>(
                          file.path, (json) => Audio.fromMap(json, false));
                    } else if (file.path.endsWith('spelling.json')) {
                      spellings = await loadItemsFromFile<Spelling>(
                          file.path, (json) => Spelling.fromMap(json));
                    } else if (file.path.endsWith('examples.json')) {
                      examples = await loadItemsFromFile<Example>(
                          file.path, (json) => Example.fromMap(json));
                    }
                  }
                }
                if (topics?.isNotEmpty == true) {
                  await db.insertCategory(category);
                  // logger(idCategory);

                  for (var topic in topics!) {
                    var idTopicUpdate = topic.id;
                    topic.id = null;
                    Topic? topicCheck = await db.checkTopicExist(topic);
                    var idTopic;
                    if (topicCheck != null) {
                      idTopic = topicCheck.id;
                    } else {
                      idTopic = await db.insertTopic(topic);
                    }

                    // logger(idTopic);

                    var rootFolder = '${request.folderPath}/${topic.category}';
                    logger(rootFolder);
                    logger(topic);
                    isolate.compute(downloadResource, [
                      topic.link_resource_default,
                      rootFolder,
                      '$rootFolder/resource_default_${topic.name}',
                      request.token
                    ]);

                    if (topic.type == TopicType.VOCABULARY.value) {
                      await db.updateDataVocabulary(
                          idTopicUpdate,
                          idTopic,
                          subTopics,
                          vocabularies,
                          audios,
                          spellings,
                          examples, (process) {
                        sendPort.send(UpdateReponse(UpdateStatus.UPDATE,
                            category: category,
                            topic: topic,
                            process: process));
                      });
                    } else {
                      await db.updateDataConversation(
                          idTopicUpdate,
                          idTopic,
                          conversations,
                          audio_conversations,
                          transcripts, (process) {
                        sendPort.send(UpdateReponse(UpdateStatus.UPDATE,
                            category: category,
                            topic: topic,
                            process: process));
                      });
                    }
                  }
                }
              }
            }
          }
        }
        fileDownload.delete();
        folder.deleteSync(recursive: true);
        sendPort.send(i + 1);
      } catch (e) {
        logger(e);
        sendPort.send(UpdateReponse(UpdateStatus.ERROR));
        return;
      }
    }
    sendPort.send(UpdateReponse(UpdateStatus.COMPLETE));
  }
}

Future<void> downloadResource(List<dynamic> argument) async {
  // try {
  String url = argument[0];
  String folderPath = argument[1];
  String pathStore = argument[2];
  var token = argument[3];

  var directoryFile = Directory(pathStore);
  if (await directoryFile.exists() == true) {
    return;
  }

  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  var directory = Directory(folderPath);
  if (await directory.exists() == false) {
    await directory.create();
  }

  final fileDownload = File('$pathStore.zip');
  Dio dio = Dio();
  await dio.download(url, fileDownload.path);
  await ZipFile.extractToDirectory(
    zipFile: fileDownload,
    destinationDir: directory,
  );
  fileDownload.deleteSync(recursive: true);
  // } catch (e) {
  //   logger(e);
  // }
}

FileSystemEntity? getFileByName(
    List<FileSystemEntity>? fileList, String fileName) {
  try {
    return fileList?.firstWhere((file) => file.path.endsWith(fileName));
  } catch (e) {
    return null;
  }
}

Future<List<T>> loadItemsFromFile<T>(
    String filePath, T Function(Map<String, dynamic>) fromJson) async {
  try {
    File file = File(filePath);
    String jsonString = await file.readAsString();
    List<dynamic> jsonList = json.decode(jsonString);

    List<T> items = jsonList.map((json) {
      return fromJson(json);
    }).toList();
    return items;
  } catch (e) {
    return [];
  }
}
