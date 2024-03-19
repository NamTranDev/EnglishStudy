import 'package:english_study/constants.dart';
import 'package:english_study/screen/main/main_screen.dart';
import 'package:english_study/screen/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: SplashViewModel(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: sky_blue,
          body: Consumer<SplashViewModel>(
            builder: (context, viewmodel, child) {
              return FutureBuilder(
                future: viewmodel.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, MainScreen.routeName, (route) => false);
                    });
                  }
                  return Container(
                    padding: EdgeInsets.all(84),
                    child: Center(
                        child: Image.asset(
                      'assets/icons/ic_laucher.png',
                      fit: BoxFit.contain,
                    )),
                  );
                },
              );
            },
          ),
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
