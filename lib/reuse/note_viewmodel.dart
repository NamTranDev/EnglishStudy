import 'package:english_study/model/example.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';

mixin NoteViewModel {
  void updateVocabulary(Vocabulary? vocabulary) {
    if (vocabulary == null) return;
    var db = getIt<DBProvider>();
    db.updateVocabulary(vocabulary);
  }

  void updateExample(Example? example) {
    if (example == null) return;
    var db = getIt<DBProvider>();
    db.updateExample(example);
  }
}
