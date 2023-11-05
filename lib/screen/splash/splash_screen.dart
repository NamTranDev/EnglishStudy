import 'dart:io';

import 'package:dio/dio.dart';
import 'package:english_study/screen/category/category_screen.dart';
import 'package:english_study/screen/flash_card/flash_card_vocabulary_screen.dart';
import 'package:english_study/screen/splash/initialize_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: InitializeViewModel(),
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(child: Consumer<InitializeViewModel>(
            builder: (context, value, child) {
              return FutureBuilder(
                future: value.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Something wrong with message: ${snapshot.error.toString()}"),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, CategoryScreen.routeName, (route) => false);
                    });
                  }
                  return ValueListenableBuilder(
                    valueListenable: value.processText,
                    builder: (context, value, child) {
                      return Center(
                        child: Text(value),
                      );
                    },
                  );
                },
              );
            },
          )),
        );
      },
    );
  }

  Widget buildSplashScreen(BuildContext context) {
    return Center(
      child: Text('This is Splash Screen'),
    );
  }
}
