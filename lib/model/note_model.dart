import 'package:english_study/model/vocabulary.dart';
import 'package:flutter/material.dart';

class NoteModel with ChangeNotifier {
  Vocabulary? _vocabulary;
  int change = 0;

  void update() {
    change++;
    notifyListeners();
  }
}
