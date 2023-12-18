import 'package:english_study/model/category.dart';
import 'package:english_study/model/category_select.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/cupertino.dart';

class CategoryViewModel {
  final ValueNotifier<CategorySelect?> _selectInfo =
      ValueNotifier<CategorySelect?>(null);
  ValueNotifier<CategorySelect?> get selectInfo => _selectInfo;

  Future<List<Category>> initData(int? type) async {
    return await getIt<DBProvider>().getCategoriesLearning(type);
  }

  void selectCategory(int index, Category? category) {
    _selectInfo.value = CategorySelect(index, category);
  }

  void comfirmCategory(int? type) {
    var categorySelect = _selectInfo.value;
    if (categorySelect == null) return;
    getIt<Preference>().setCurrentCategory(type, categorySelect.category?.key);
  }
}
