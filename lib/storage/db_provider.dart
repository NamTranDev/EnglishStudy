import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:english_study/model/audio.dart';
import 'package:english_study/model/example.dart';
import 'package:english_study/model/spelling.dart';
import 'package:english_study/model/sub_topic.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/model/vocabulary.dart';
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

  final _TOPIC_TABLE = "topics";
  final _SUB_TOPIC_TABLE = "sub_topics";
  final _VOCABULARY_TABLE = "vocabulary";
  final _AUDIO_TABLE = "audio";
  final _SPELLING_TABLE = "spelling";
  final _EXAMPLE_TABLE = "examples";

  Future<Database> get _db async {
    if (_database != null) return _database!;
    // if _database is null we instantiate it
    _database = await _initDB();
    return _database!;
  }

  _initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "CEFR_Wordlist.db");

    var exists = await databaseExists(path);
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load('assets/CEFR_Wordlist.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path);
  }

  Future<List<String>> getCategorys() async {
    final db = await _db;
    var res = await db.query(_TOPIC_TABLE,
        columns: ['category'], groupBy: 'category');
    List<String> list =
        res.isNotEmpty ? res.map((c) => c['category'] as String).toList() : [];
    return list;
  }

  Future<List<Topic>> getTopics(String? category) async {
    final db = await _db;
    var res = await db
        .query(_TOPIC_TABLE, where: 'category = ?', whereArgs: [category]);
    List<Topic> list =
        res.isNotEmpty ? res.map((c) => Topic.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<SubTopic>> getSubTopics(String? topicId) async {
    final db = await _db;
    var res = await db
        .query(_SUB_TOPIC_TABLE, where: 'topic_id = ?', whereArgs: [topicId]);
    List<SubTopic> list =
        res.isNotEmpty ? res.map((c) => SubTopic.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Vocabulary>> getVocabulary(String? sub_topic_id) async {
    final db = await _db;
    var res = await db.query(_VOCABULARY_TABLE,
        where: 'sub_topic_id = ?', whereArgs: [sub_topic_id]);
    Iterable<Future<Vocabulary>> mappedList = res.isNotEmpty
        ? res.map((c) async {
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
            vocabulary.examples =
                examples.map((e) => Example.fromMap(e)).toList();
            return vocabulary;
          }).toList()
        : [];
    Future<List<Vocabulary>> futureList = Future.wait(mappedList);
    List<Vocabulary> result = await futureList;
    return result;
  }
}
