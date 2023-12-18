import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:english_study/download/download_manager.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/category.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/transcript.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/model/spelling.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<DBProvider> initDBProvider() async {
  DBProvider dbProvider = DBProvider._();
  dbProvider._initDB();
  return dbProvider;
}

class DBProvider {
  DBProvider._();

  Database? _database;

  final _CATEGORY_TABLE = "category";
  final _TOPIC_TABLE = "topics";
  final _SUB_TOPIC_TABLE = "sub_topics";
  final _CONVERSATION_TABLE = "conversation";
  final _VOCABULARY_TABLE = "vocabulary";
  final _AUDIO_TABLE = "audio";
  final _AUDIO_CONVERSATION_TABLE = "audio_conversation";
  final _SPELLING_TABLE = "spelling";
  final _TRANSCRIPT_TABLE = "transcript";
  final _EXAMPLE_TABLE = "examples";

  Future<Database> get _db async {
    if (_database != null) return _database!;
    // if _database is null we instantiate it
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "english.db");

    // deleteDatabase(path);

    var exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load('assets/english.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path);
  }

  Future<List<Category>> getCategoriesLearning(int? type) async {
    final db = await _db;
    var res = await db.rawQuery('''
      SELECT c.*
      FROM "category" c
      JOIN "topics" t ON c."key" = t."category"
      WHERE t."type" = $type AND t."isLearnComplete" == 0
      GROUP BY t."category";
    ''');
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Category>> getCategoriesComplete() async {
    final db = await _db;
    var res = await db.rawQuery('''
      SELECT c.*
      FROM "category" c
      JOIN "topics" t ON c."key" = t."category"
      WHERE t."isLearnComplete" == 1
      GROUP BY t."category";
    ''');
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Topic>> getTopics(String? category, int? type) async {
    final db = await _db;
    var res = await db.query(_TOPIC_TABLE,
        where: 'category = ? and type = ?', whereArgs: [category, type]);
    List<Topic> list = await mapperTopic(db, res, category);
    bool hasLearning = list.any(
        (element) => element.isLearnComplete == 0 && element.isLearning == 1);
    if (!hasLearning) {
      var topic = list.firstWhereOrNull(
          (element) => element.isLearnComplete == 0 && element.isLearning == 0);
      if (topic != null) {
        topic.isLearning = 1;
        await updateTopic(topic);
      }
    }
    list.sort((a, b) {
      int compareLearnComplete =
          a.isLearnComplete!.compareTo(b.isLearnComplete!);

      if (compareLearnComplete == 1) {
        return a.isLearning!.compareTo(b.isLearning!);
      } else {
        return compareLearnComplete;
      }
    });
    return list;
  }

  Future<List<Topic>> getTopicsSimple(String? category, int? type) async {
    final db = await _db;
    var res = await db.query(_TOPIC_TABLE,
        where: 'category = ? and type = ?', whereArgs: [category, type]);

    return res.map((e) => Topic.fromMap(e)).toList();
  }

  Future<List<Topic>> getAllTopics() async {
    final db = await _db;
    var res = await db.query(_TOPIC_TABLE);
    List<Topic> list = await mapperTopic(db, res, null);
    return list;
  }

  Future<List<Conversation>> getConversations(String? topicId) async {
    final db = await _db;
    var res = await db.query(_CONVERSATION_TABLE,
        where: 'topic_id = ?', whereArgs: [topicId]);
    List<Conversation> convesations =
        res.isNotEmpty ? res.map((c) => Conversation.fromMap(c)).toList() : [];
    bool hasLearning = convesations.any(
        (element) => element.isLearnComplete == 0 && element.isLearning == 1);
    if (!hasLearning) {
      var conversation = convesations.firstWhereOrNull(
          (element) => element.isLearnComplete == 0 && element.isLearning == 0);
      if (conversation == null) return convesations;
      conversation.isLearning = 1;
      await updateConversation(conversation);
    }
    return convesations;
  }

  Future<Conversation> getConversationDetail(String? id) async {
    final db = await _db;
    var res =
        await db.query(_CONVERSATION_TABLE, where: 'id = ?', whereArgs: [id]);
    return mapperConversation(db, res);
  }

  Future<List<SubTopic>> getSubTopics(String? topicId) async {
    final db = await _db;
    var res = await db
        .query(_SUB_TOPIC_TABLE, where: 'topic_id = ?', whereArgs: [topicId]);
    List<SubTopic> list = await mapperSubTopic(res);

    bool hasLearning = list.any(
        (element) => element.isLearnComplete == 0 && element.isLearning == 1);
    if (!hasLearning) {
      var subTopic = list.firstWhereOrNull(
          (element) => element.isLearnComplete == 0 && element.isLearning == 0);
      if (subTopic == null) return list;
      subTopic.isLearning = 1;
      await updateSubTopic(subTopic);
    }
    return list;
  }

  Future<List<Vocabulary>> getVocabulary(String? sub_topic_id) async {
    final db = await _db;
    var res = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ?', whereArgs: [sub_topic_id]);

    List<Vocabulary> result = await mapperVocabulary(db, res);
    result.sort((a, b) {
      if (b.isLearn == null && a.isLearn != null) {
        return 1; // Nulls go to the end
      } else if (a.isLearn == null && b.isLearn != null) {
        return -1; // Nulls go to the end
      } else {
        return (b.isLearn ?? 0).compareTo(a.isLearn ?? 0);
      }
    });
    return result;
  }

  Future<List<SubTopic>> mapperSubTopic(
      List<Map<String, Object?>> values) async {
    Iterable<Future<SubTopic>> mappedList = values.isNotEmpty
        ? values.map((c) async {
            SubTopic subtopic = SubTopic.fromMap(c);

            subtopic.processLearn = await progressSubTopic(subtopic);

            return subtopic;
          }).toList()
        : [];
    return Future.wait(mappedList);
  }

  Future<double> progressSubTopic(SubTopic subtopic) async {
    final db = await _db;
    final numberLearn = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM $_VOCABULARY_TABLE WHERE sub_topic_id = ${subtopic.id} AND isLearn = 1')) ??
        0;
    final total = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM $_VOCABULARY_TABLE WHERE sub_topic_id = ${subtopic.id}')) ??
        1;
    return numberLearn / total;
  }

  Future<List<Topic>> mapperTopic(
    Database db,
    List<Map<String, Object?>> values,
    String? category,
  ) async {
    Iterable<Future<Topic>> mappedList = values.isNotEmpty
        ? values.map((c) async {
            Topic topic = Topic.fromMap(c);
            var path =
                "${getIt<AppMemory>().pathFolderDocument}/${getIt<Preference>().currentCategory(topic.type)}/${topic.name}";
            var _downloadManager = getIt<DownloadManager>();
            var processItems = _downloadManager.hasProcessItems(category);
            if (processItems != null) {
              topic.isDownload = processItems[topic.link_resource]?.status ==
                      DownloadStatus.COMPLETE
                  ? 1
                  : 0;
            } else {
              Directory dir = Directory(path);
              var isExist = dir.existsSync();
              if (!isExist) {
                updateDownloadTopic(topic.link_resource, '0');
              } else {
                if (topic.isDownload == 0) {
                  dir.deleteSync(recursive: true);
                }
              }
              topic.isDownload = topic.isDownload == 1 && isExist ? 1 : 0;
            }
            return topic;
          }).toList()
        : [];
    return Future.wait(mappedList);
  }

  Future<List<Vocabulary>> mapperVocabulary(
      Database db, List<Map<String, Object?>> values) async {
    Iterable<Future<Vocabulary>> mappedList = values.isNotEmpty
        ? values.map((c) async {
            Vocabulary vocabulary = Vocabulary.fromMap(c);
            var audios = await db.query(_AUDIO_TABLE,
                where: 'vocabulary_id = ?', whereArgs: [vocabulary.id]);
            var spellings = await db.query(_SPELLING_TABLE,
                where: 'vocabulary_id = ?', whereArgs: [vocabulary.id]);
            var examples = await db.query(_EXAMPLE_TABLE,
                where: 'vocabulary_id = ?', whereArgs: [vocabulary.id]);
            vocabulary.audios = audios.map((e) => Audio.fromMap(e)).toList();
            vocabulary.spellings =
                spellings.map((e) => Spelling.fromMap(e)).toList();
            vocabulary.examples = examples.map((e) {
              Example example = Example.fromMap(e);
              example.sentence = example.sentence
                  ?.replaceAll('"', '')
                  .replaceAll(RegExp(r'^\d+\.\s'), "");
              return example;
            }).toList();
            return vocabulary;
          }).toList()
        : [];
    return Future.wait(mappedList);
  }

  Future<Conversation> mapperConversation(
      Database db, List<Map<String, Object?>> values) async {
    Conversation conversation = Conversation.fromMap(values.first);
    var audios = await db.query(_AUDIO_CONVERSATION_TABLE,
        where: 'conversation_id = ?', whereArgs: [conversation.id]);
    var transcipt = await db.query(_TRANSCRIPT_TABLE,
        where: 'conversation_id = ?', whereArgs: [conversation.id]);

    conversation.audios = audios.map((e) => Audio.fromMap(e)).toList();
    conversation.transcript =
        transcipt.map((e) => Transcript.fromMap(e)).toList();
    return conversation;
  }

  Future<void> updateTopic(Topic topic) async {
    final db = await _db;
    await db.update(_TOPIC_TABLE, topic.toMap(),
        where: 'id = ?', whereArgs: [topic.id]);
  }

  Future<void> updateSubTopic(SubTopic? subTopic) async {
    if (subTopic == null) return;
    final db = await _db;
    await db.update(_SUB_TOPIC_TABLE, subTopic.toMap(),
        where: 'id = ?', whereArgs: [subTopic.id]);
  }

  Future<void> updateConversation(Conversation? conversation) async {
    if (conversation == null) return;
    final db = await _db;
    await db.update(_CONVERSATION_TABLE, conversation.toMap(),
        where: 'id = ?', whereArgs: [conversation.id]);
  }

  Future<bool> updateVocabulary(Vocabulary? vocabulary) async {
    if (vocabulary == null) return false;
    final db = await _db;
    await db.update(_VOCABULARY_TABLE, vocabulary.toMap(),
        where: 'id = ?', whereArgs: [vocabulary.id]);

    var result = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ? and isLearn = 0',
        whereArgs: [vocabulary.sub_topic_id]);
    var list = await mapperVocabulary(db, result);
    print(list.length);
    return result.isEmpty;
  }

  Future<bool> syncSubTopic(String? subTopicId) async {
    if (subTopicId == null) return false;
    final db = await _db;
    var result = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ? and isLearn = 0', whereArgs: [subTopicId]);
    if (result.isEmpty) {
      db.rawUpdate(
          'UPDATE ${_SUB_TOPIC_TABLE} SET isLearnComplete = 1 WHERE id = ?',
          [subTopicId]);
      return true;
    }
    return false;
  }

  Future<bool> syncTopic(String? id) async {
    if (id == null) return false;
    final db = await _db;
    var result = await db.query(_SUB_TOPIC_TABLE,
        where: 'topic_id = ? and isLearnComplete = 0', whereArgs: [id]);
    if (result.isEmpty) {
      final numberNotLearn =
          Sqflite.firstIntValue(await db.rawQuery("""SELECT COUNT(*)
            FROM "topics"
            WHERE "category" = (
                SELECT "category"
                FROM ${_TOPIC_TABLE}
                WHERE "id" = ${id}
            )
            AND "isLearnComplete" = 0;""")) ?? 0;
      if (numberNotLearn != 1) {
        syncTopicComplete(id);
      }
      return true;
    }
    return false;
  }

  Future<bool> checkCategory(Topic? topic) async {
    if (topic == null) return false;
    var isComplete = await checkTopicComplete(topic);
    if (isComplete) {
      topic.isLearnComplete = 1;
      // await syncTopicComplete(topic.id.toString());
      // return await checkCategoryComplete(topic.category);
      var topics = await getTopicsSimple(topic.category, topic.type);
      return topics
          .where((element) =>
              element.isLearnComplete == 0 && element.id != topic.id)
          .isEmpty;
    }
    return false;
  }

  Future<bool> checkCategoryComplete(String? category) async {
    if (category == null) return false;
    final db = await _db;
    final result = await db.rawQuery('''
    SELECT t.*
    FROM ${_TOPIC_TABLE} t
    JOIN ${_CATEGORY_TABLE} c ON c."key" = t."category"
    WHERE c."key" = ?
    GROUP BY t."id"
    HAVING COUNT(t."id") = COUNT(CASE WHEN t."isLearnComplete" = 0 THEN 1 ELSE NULL END);
  ''', [category]);

    return result.isEmpty;
  }

  Future<void> syncTopicComplete(String? id) async {
    final db = await _db;
    db.rawUpdate(
        'UPDATE ${_TOPIC_TABLE} SET isLearnComplete = 1 WHERE id = ?', [id]);
  }

  Future<bool> syncTopicConversation(Topic? topic) async {
    if (topic == null) return false;
    final db = await _db;
    var result = await db.query(_CONVERSATION_TABLE,
        where: 'topic_id = ? and isLearnComplete = 0', whereArgs: [topic.id]);
    if (result.isEmpty) {
      db.rawUpdate(
          'UPDATE ${_TOPIC_TABLE} SET isLearnComplete = 1 WHERE id = ?',
          [topic.id]);
      return checkCategoryComplete(topic.category);
    }
    return false;
  }

  Future<bool> checkConversationLearn(String? id) async {
    if (id == null) return false;
    final db = await _db;
    var result = await db.query(_CONVERSATION_TABLE,
        where: 'id = ? and isLearnComplete = 1', whereArgs: [id]);
    return result.isNotEmpty;
  }

  Future<void> syncConversation(String? id) async {
    if (id == null) return;
    final db = await _db;
    db.rawUpdate(
        'UPDATE ${_CONVERSATION_TABLE} SET isLearnComplete = 1 WHERE id = ?',
        [id]);
  }

  Future<void> updateDownloadTopic(String? key, String value) async {
    final db = await _db;
    var count = await db.rawUpdate(
        'UPDATE ${_TOPIC_TABLE} SET isDownload = ? WHERE link_topic = ?',
        [value, key]);
    print(key);
    print(count);
  }

  Future<List<GameVocabularyModel>> vocabularyGameSubTopic(
      String sub_topic_id) async {
    final db = await _db;
    var res = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ?', whereArgs: [sub_topic_id]);

    return _vocabularyGame(await mapperVocabulary(db, res));
  }

  Future<List<GameVocabularyModel>> vocabularyGameLearn(
      {int? limit = 100}) async {
    final db = await _db;
    var res =
        await db.query(_VOCABULARY_TABLE, where: 'isLearn = 1', limit: limit);

    return _vocabularyGame(await mapperVocabulary(db, res));
  }

  List<GameVocabularyModel> _vocabularyGame(List<Vocabulary> vocabularies) {
    List<GameVocabularyModel> vocabularyGames = [];
    vocabularies.shuffle();
    vocabularies.forEach((vocabulary) {
      try {
        var list = _getRandomItemsWithDifferentIds(vocabularies, vocabulary);
        list.add(vocabulary);
        list.shuffle();
        vocabularyGames
            .add(GameVocabularyModel(main: vocabulary, vocabularies: list));
      } catch (e) {
        print(e);
      }
    });
    return vocabularyGames;
  }

  List<Vocabulary> _getRandomItemsWithDifferentIds(
      List<Vocabulary> list, Vocabulary itemMain) {
    if (list.length < 3) {
      throw Exception("List must contain at least three items.");
    }

    final random = Random();
    final selectedItems = <Vocabulary>[];
    while (selectedItems.length < 3) {
      final randomIndex = random.nextInt(list.length);
      final selectedItem = list[randomIndex];

      // Check if the selected item's ID is not equal to itemMain's ID
      // and it's not already in selectedItems
      if (selectedItem.id != itemMain.id &&
          !selectedItems.any((item) => item.id == selectedItem.id)) {
        selectedItems.add(selectedItem);
      }
    }

    return selectedItems;
  }

  Future<bool> hasCategoryToLearn(int type) async {
    final db = await _db;
    return (Sqflite.firstIntValue(await db
                .rawQuery("""SELECT COUNT(DISTINCT c."key") AS countCategories
FROM ${_CATEGORY_TABLE} c
JOIN ${_TOPIC_TABLE} t ON c."key" = t."category"
WHERE t."type" = ${type} AND t."isLearnComplete" = 0;""")) ??
            0) >
        0;
  }

  Future<bool> hasCategoryLearnComplete() async {
    final db = await _db;
    final result = await db.rawQuery('''
    SELECT c.*
    FROM ${_CATEGORY_TABLE} c
    WHERE NOT EXISTS (
        SELECT 1
        FROM ${_TOPIC_TABLE} t
        WHERE t."category" = c."key"
          AND t."isLearnComplete" <> 1
    );
  ''');
    return result.isNotEmpty;
  }

  Future<bool> checkTopicComplete(Topic? topic) async {
    if (topic == null) return false;
    final db = await _db;
    return (Sqflite.firstIntValue(await db.rawQuery("""SELECT COUNT(*)
FROM ${topic.type == TabType.VOCABULARY.value ? _SUB_TOPIC_TABLE : _CONVERSATION_TABLE}
WHERE topic_id = ${topic.id} and isLearnComplete = 0
;""")) ?? 0) == 0;
  }
}
