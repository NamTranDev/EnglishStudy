import 'package:english_study/screen/category/category_screen.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = '/splash';

  const SplashScreen({super.key});

  Future initialize() async {
    return Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        initialData: false,
        future: initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushNamedAndRemoveUntil(
                  context, CategoryScreen.routeName, (route) => false);
            });
          }
          return buildSplashScreen(context);
        },
      ),
    );
  }

  Widget buildSplashScreen(BuildContext context) {
    return Center(
      child: Text('This is Splash Screen'),
    );
  }
}
