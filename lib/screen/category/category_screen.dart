import 'package:english_study/screen/topic/topic_screen.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  static String routeName = '/category';
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var db = getIt<DBProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Category')),
      ),
      body: SafeArea(
          child: FutureBuilder(
        future: db.getCategorys(),
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
      )),
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
              onTap: () {
                Navigator.pushNamed(context, TopicScreen.routeName,
                    arguments: categories?[index]);
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
