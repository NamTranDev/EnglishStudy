import 'package:english_study/model/topic.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  static String routeName = '/category';
  final Function onPickCategory;
  final int? type;
  const CategoryScreen(
      {super.key, required this.onPickCategory, required this.type});

  @override
  Widget build(BuildContext context) {
    var db = getIt<DBProvider>();
    return FutureBuilder(
      future: db.getCategorys(type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
                "Something wrong with message: ${snapshot.error.toString()}"),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return buildListCategory(context, snapshot.data);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget buildListCategory(BuildContext context, List<String>? categories) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                getIt<Preference>()
                    .setCurrentCategory(type, categories?[index]);
                onPickCategory.call();
              },
              child: Text(
                categories?[index] ?? '',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      itemCount: categories?.length ?? 0,
    );
  }
}
