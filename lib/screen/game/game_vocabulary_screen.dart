import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/model/game_vocabulary_model.dart';
import 'package:english_study/screen/game/game_vocabulary_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../storage/db_provider.dart';

class GameVocabularyScreen extends StatefulWidget {
  static String routeName = '/vocabulary_name';
  const GameVocabularyScreen({super.key});

  @override
  State<GameVocabularyScreen> createState() => _GameVocabularyScreenState();
}

class _GameVocabularyScreenState extends State<GameVocabularyScreen> {
  @override
  Widget build(BuildContext context) {
    var db = getIt<DBProvider>();
    String? subTopicId = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: subTopicId == null
            ? db.vocabularyGameLearn()
            : db.vocabularyGameSubTopic(subTopicId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  "Something wrong with message: ${snapshot.error.toString()}"),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            // return buildListCategory(context, snapshot.data);
            return Provider.value(
              value: GameVocabularyViewModel(snapshot.data),
              builder: (context, child) {
                return Container();
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
