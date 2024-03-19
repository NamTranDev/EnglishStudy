import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:english_study/download/download_manager.dart';
import 'package:english_study/download/download_status.dart';
import 'package:english_study/logger.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/category.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/transcript.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/model/topic_type.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/model/spelling.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<DBProvider> initDBProvider(String folderPath, ByteData assetByte) async {
  DBProvider dbProvider = DBProvider._(folderPath, assetByte);
  await dbProvider.initDB();
  return dbProvider;
}

class DBProvider {
  final String folderPath;
  final ByteData assetByte;
  DBProvider._(this.folderPath, this.assetByte);

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
    initDB();
    return _database!;
  }

  Future<void> initDB() async {
    databaseFactoryOrNull = null;
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
    }
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
    // this step, it will use the sqlite version available on the system.
    databaseFactory = databaseFactoryFfi;

    var path = join(folderPath, "english.db");

    // deleteDatabase(path);

    var exists = await databaseExists(path);
    logger(exists);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      List<int> bytes = assetByte.buffer
          .asUint8List(assetByte.offsetInBytes, assetByte.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    _database = await openDatabase(path);
    logger(_database);
  }

  Database? getDatabase() {
    return _database;
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
        GROUP BY c."key"
        HAVING COUNT(t."id") = COUNT(CASE WHEN t."isLearnComplete" = 1 THEN 1 ELSE NULL END);
    ''');
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Topic>> getTopicsTest(String category) async {
    final db = await _db;
    var res = await db.query(_TOPIC_TABLE, where: 'category = ?', whereArgs: [
      category,
    ]);
    List<Topic> list = await mapperTopic(db, res, category);
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

  Future<List<Topic>> getTopicsComplete(String? category) async {
    final db = await _db;
    var res = await db
        .query(_TOPIC_TABLE, where: 'category = ?', whereArgs: [category]);
    List<Topic> list = await mapperTopic(db, res, category);
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

  Future<List<Conversation>> getConversations(
      String? topicId, bool isGetDetail) async {
    final db = await _db;
    var res = await db.query(_CONVERSATION_TABLE,
        where: 'topic_id = ?', whereArgs: [topicId]);
    List<Conversation> convesations;
    if (isGetDetail) {
      Iterable<Future<Conversation>> iterable = res.isNotEmpty
          ? res.map((c) async {
              return mapperConversation(db, c);
            }).toList()
          : [];
      convesations = await Future.wait(iterable);
    } else {
      convesations = res.isNotEmpty
          ? res.map((c) => Conversation.fromMap(c)).toList()
          : [];
    }
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
    return mapperConversation(db, res.first);
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
            vocabulary.audios =
                audios.map((e) => Audio.fromMap(e, false)).toList();
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
      Database db, Map<String, Object?> values) async {
    Conversation conversation = Conversation.fromMap(values);
    var audios = await db.query(_AUDIO_CONVERSATION_TABLE,
        where: 'conversation_id = ?', whereArgs: [conversation.id]);
    var transcipt = await db.query(_TRANSCRIPT_TABLE,
        where: 'conversation_id = ?', whereArgs: [conversation.id]);

    conversation.audios = audios.map((e) => Audio.fromMap(e, true)).toList();
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

  Future<bool> updateAndCheckVocabulary(Vocabulary? vocabulary) async {
    if (vocabulary == null) return false;
    updateVocabulary(vocabulary);

    final db = await _db;
    var result = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ? and isLearn = 0',
        whereArgs: [vocabulary.sub_topic_id]);
    var list = await mapperVocabulary(db, result);
    print(list.length);
    return result.isEmpty;
  }

  Future<void> updateVocabulary(Vocabulary vocabulary) async {
    final db = await _db;
    logger(vocabulary.toMap());
    await db.update(_VOCABULARY_TABLE, vocabulary.toMap(),
        where: 'id = ?', whereArgs: [vocabulary.id]);
  }

  Future<void> updateExample(Example example) async {
    final db = await _db;
    logger(example.toMap());
    await db.update(_EXAMPLE_TABLE, example.toMap(),
        where: 'vocabulary_id = ? and example = ?',
        whereArgs: [example.vocabulary_id, example.sentence]);
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

  Future<bool?> checkCategoryExist(String? key) async {
    if (key == null) return null;
    final db = await _db;
    List<Map<String, dynamic>> result = await db.query(
      _CATEGORY_TABLE,
      where: 'key = ?',
      whereArgs: [key],
    );
    return result.isNotEmpty;
  }

  Future<Topic?> checkTopicExist(Topic topic) async {
    final db = await _db;
    List<Map<String, dynamic>> res = await db.query(
      _TOPIC_TABLE,
      where:
          'topic_name = ? and number_lessons = ? and total_words = ? and description_topic = ? and category = ?',
      whereArgs: [
        topic.name,
        topic.number_sub_topic,
        topic.total_word,
        topic.description,
        topic.category
      ],
    );
    return res.map((e) => Topic.fromMap(e)).toList().getOrNull(0);
  }

  Future<SubTopic?> checkSubTopicExist(Database db, SubTopic subTopic) async {
    var res = await db.query(
      _SUB_TOPIC_TABLE,
      where:
          'topic_id = ? and sub_topic_name = ? and number_sub_topic_words = ?',
      whereArgs: [subTopic.topic_id, subTopic.name, subTopic.number_word],
    );

    return res.map((e) => SubTopic.fromMap(e)).toList().getOrNull(0);
  }

  Future<Conversation?> checkConversationExist(
      Database db, Conversation conversation) async {
    List<Map<String, dynamic>> res = await db.query(
      _CONVERSATION_TABLE,
      where: 'topic_id = ? and conversation_lession = ?',
      whereArgs: [conversation.topic_id, conversation.conversation_lession],
    );
    return res.map((e) => Conversation.fromMap(e)).toList().getOrNull(0);
  }

  Future<Vocabulary?> checkVocabularyExist(
      Database db, Vocabulary vocabulary) async {
    List<Map<String, dynamic>> res = await db.query(
      _VOCABULARY_TABLE,
      where:
          'sub_topic_id = ? and vocabulary = ? and image_file_name = ? and word_type = ? and description = ?',
      whereArgs: [
        vocabulary.sub_topic_id,
        vocabulary.word,
        vocabulary.image_file_name,
        vocabulary.word_type,
        vocabulary.description
      ],
    );
    return res.map((e) => Vocabulary.fromMap(e)).toList().getOrNull(0);
  }

  Future<Transcript?> checkTranscriptExist(
      Database db, Transcript transcript) async {
    List<Map<String, dynamic>> res = await db.query(
      _TRANSCRIPT_TABLE,
      where: 'conversation_id = ? and script = ?',
      whereArgs: [
        transcript.conversation_id,
        transcript.script,
      ],
    );
    return res.map((e) => Transcript.fromMap(e)).toList().getOrNull(0);
  }

  Future<Audio?> checkAudioVocabularyExist(Database db, Audio audio) async {
    List<Map<String, dynamic>> res = await db.query(
      _AUDIO_TABLE,
      where:
          'vocabulary_id = ? and audio_file_name = ? and audio_file_path = ?',
      whereArgs: [
        audio.vocabulary_id,
        audio.name,
        audio.path,
      ],
    );
    return res.map((e) => Audio.fromMap(e, false)).toList().getOrNull(0);
  }

  Future<Audio?> checkAudioConversationExist(Database db, Audio audio) async {
    List<Map<String, dynamic>> res = await db.query(
      _AUDIO_CONVERSATION_TABLE,
      where:
          'conversation_id = ? and audio_file_name = ? and audio_file_path = ?',
      whereArgs: [
        audio.conversation_id,
        audio.name,
        audio.path,
      ],
    );
    return res.map((e) => Audio.fromMap(e, false)).toList().getOrNull(0);
  }

  Future<Spelling?> checkSpellingExist(Database db, Spelling spelling) async {
    List<Map<String, dynamic>> res = await db.query(
      _SPELLING_TABLE,
      where: 'vocabulary_id = ? and spelling_text = ?',
      whereArgs: [
        spelling.vocabulary_id,
        spelling.spelling,
      ],
    );
    return res.map((e) => Spelling.fromMap(e)).toList().getOrNull(0);
  }

  Future<Example?> checkExampleExist(Database db, Example example) async {
    List<Map<String, dynamic>> res = await db.query(
      _EXAMPLE_TABLE,
      where: 'vocabulary_id = ? and example = ?',
      whereArgs: [
        example.vocabulary_id,
        example.sentence,
      ],
    );
    return res.map((e) => Example.fromMap(e)).toList().getOrNull(0);
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
    var test = await getAllTopics();
    logger(test);
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
FROM ${topic.type == TopicType.VOCABULARY.value ? _SUB_TOPIC_TABLE : _CONVERSATION_TABLE}
WHERE topic_id = ${topic.id} and isLearnComplete = 0
;""")) ?? 0) == 0;
  }

  Future<int> insertCategory(Category category) async {
    final db = await _db;
    return await db.insert(_CATEGORY_TABLE, category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertTopic(Topic topic) async {
    final db = await _db;
    return await db.rawInsert('''
      INSERT INTO ${_TOPIC_TABLE} (
        "topic_name", "topic_image", "number_lessons", "total_words",
        "description_topic", "link_topic", "category", "isDefault", "type"
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      topic.name,
      topic.image,
      topic.number_sub_topic,
      topic.total_word,
      topic.description,
      topic.link_resource,
      topic.category,
      topic.isDefault,
      topic.type,
    ]);
  }

  Future<void> updateDataVocabulary(
      int? idTopicUpdate,
      int? idTopic,
      List<SubTopic>? subTopics,
      List<Vocabulary>? vocabularies,
      List<Audio>? audios,
      List<Spelling>? spellings,
      List<Example>? examples,
      Function? onProcess) async {
    final db = await _db;
    var total = 0;
    int index = 0;
    var subTopicList = subTopics
        ?.where((element) => element.topic_id == idTopicUpdate)
        .map((e) {
      try {
        total += int.parse(e.number_word?.replaceAll(' Words', '') ?? '0');
      } catch (e) {
        logger(e);
      }
      return e;
    }).toList();
    for (int indexSubTopic = 0;
        indexSubTopic < (subTopicList?.length ?? 0);
        indexSubTopic++) {
      var subTopic = subTopicList?.getOrNull(indexSubTopic);
      if (subTopic == null) continue;
      var idSubTopicUpdate = subTopic.id;
      subTopic.id = null;
      subTopic.topic_id = idTopic;

      var subTopicCheck = await checkSubTopicExist(db, subTopic);
      var subTopicId;
      if (subTopicCheck != null) {
        subTopicId = subTopicCheck.id;
      } else {
        subTopicId = await db.insert(_SUB_TOPIC_TABLE, subTopic.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      logger(subTopicId);

      var vocabularyList = vocabularies
          ?.where((element) => element.sub_topic_id == idSubTopicUpdate)
          .toList();
      for (int indexVocabulary = 0;
          indexVocabulary < (vocabularyList?.length ?? 0);
          indexVocabulary++) {
        var vocabulary = vocabularyList?.getOrNull(indexVocabulary);
        if (vocabulary == null) continue;
        var idVocabularyUpdate = vocabulary.id;
        vocabulary.id = null;
        vocabulary.sub_topic_id = subTopicId;

        var vocabularyCheck = await checkVocabularyExist(db, vocabulary);
        var vocabularyId;
        if (vocabularyCheck != null) {
          vocabularyId = vocabularyCheck.id;
        } else {
          vocabularyId = await db.insert(_VOCABULARY_TABLE, vocabulary.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        logger(total);
        index++;
        var process = index / total;
        logger(process);

        onProcess?.call(process);

        var audioList = audios
            ?.where((audio) => audio.vocabulary_id == idVocabularyUpdate)
            .toList();

        for (int indexAudio = 0;
            indexAudio < (audioList?.length ?? 0);
            indexAudio++) {
          var audio = audioList?.getOrNull(indexAudio);
          if (audio == null) continue;
          audio.vocabulary_id = vocabularyId;
          var audioCheck = await checkAudioVocabularyExist(db, audio);
          if (audioCheck == null) {
            await db.insert(_AUDIO_TABLE, audio.toMap(false),
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
        var exampleList = examples
            ?.where((example) => example.vocabulary_id == idVocabularyUpdate)
            .toList();
        for (int indexExample = 0;
            indexExample < (exampleList?.length ?? 0);
            indexExample++) {
          var example = exampleList?.getOrNull(indexExample);
          if (example == null) continue;
          example.vocabulary_id = vocabularyId;
          var exampleCheck = await checkExampleExist(db, example);
          if (exampleCheck == null) {
            await db.insert(_EXAMPLE_TABLE, example.toMap(),
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
        var spellingList = spellings
            ?.where((spelling) => spelling.vocabulary_id == idVocabularyUpdate)
            .toList();
        for (int indexSpelling = 0;
            indexSpelling < (spellingList?.length ?? 0);
            indexSpelling++) {
          var spelling = spellingList?.getOrNull(indexSpelling);
          if (spelling == null) continue;
          spelling.vocabulary_id = vocabularyId;
          var spellingCheck = await checkSpellingExist(db, spelling);
          if (spellingCheck == null) {
            await db.insert(_SPELLING_TABLE, spelling.toMap(),
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
    }
  }

  Future<void> updateDataConversation(
      int? idTopicUpdate,
      int idTopic,
      List<Conversation>? conversations,
      List<Audio>? audio_conversations,
      List<Transcript>? transcripts,
      Function? onProcess) async {
    var db = await _db;
    var conversationList = conversations
        ?.where((conversation) => conversation.topic_id == idTopicUpdate)
        .toList();
    var total = conversationList?.length ?? 1;
    logger(total);
    int index = 0;
    for (int i = 0; i < (conversationList?.length ?? 0); i++) {
      var conversation = conversationList?.getOrNull(i);
      logger(conversation);
      if (conversation == null) continue;
      var idConversationUpdate = conversation.id;
      conversation.id = null;
      conversation.topic_id = idTopic;
      var conversationCheck = await checkConversationExist(db, conversation);
      var idConversation;
      if (conversationCheck != null) {
        idConversation = conversationCheck.id;
      } else {
        idConversation = await db.insert(
            _CONVERSATION_TABLE, conversation.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      logger(idConversation);

      index++;
      var process = index / total;
      logger(process);

      onProcess?.call(process);

      var audioList = audio_conversations
          ?.where((audio) => audio.conversation_id == idConversationUpdate)
          .toList();
      for (int indexAudio = 0;
          indexAudio < (audioList?.length ?? 0);
          indexAudio++) {
        var audio = audioList?.getOrNull(indexAudio);
        if (audio == null) continue;
        audio.conversation_id = idConversation;
        var audioCheck = await checkAudioConversationExist(db, audio);
        if (audioCheck == null) {
          await db.insert(_AUDIO_CONVERSATION_TABLE, audio.toMap(true),
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
      var transcriptList = transcripts
          ?.where((transcript) =>
              transcript.conversation_id == idConversationUpdate)
          .toList();
      for (int indexTranscript = 0;
          indexTranscript < (transcriptList?.length ?? 0);
          indexTranscript++) {
        var transcript = transcriptList?.getOrNull(indexTranscript);
        if (transcript == null) continue;
        transcript.conversation_id = idConversation;
        var transcriptCheck = await checkTranscriptExist(db, transcript);
        if (transcriptCheck == null) {
          await db.insert(_TRANSCRIPT_TABLE, transcript.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
  }

  Future<void> deleteAllDataRelate(String? key) async {
    var db = await _db;
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      batchDeleteFromCategory(batch, key);
      // Execute the batch
      await batch.commit(noResult: true);
    });
  }

  void batchDeleteFromCategory(Batch batch, categoryKey) {
    batch.delete(
      'category',
      where: 'key = ?',
      whereArgs: [categoryKey],
    );
  }
}
