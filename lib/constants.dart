import 'dart:io';

import 'package:english_study/model/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';

const Color color_primary = Color(0xFF2E4B5C);

const Color maastricht_blue = Color(0xFF011627);
const Color ruddy = Color(0xFFF89292);
const Color turquoise = Color(0xFF6DD2A0);
const Color baby_powder = Color(0xFFFDFFFC);
const Color red_violet = Color(0xFFB91372);

const Color disable = Color.fromARGB(255, 215, 215, 198);

const int duration_animation_screen = 300;
const int duration_animation_right_wrong = 200;
const int duration_animation_next = 300;
const double size_icon = 30;

ThemeData themeInfo = ThemeData(
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 50,
      color: Colors.black,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: maastricht_blue,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      color: maastricht_blue,
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
    },
  ),
);

Widget widgetImage(String? image, {BoxFit? fit}) {
  return image != null
      ? Image.file(
          File(
              "${getIt<AppMemory>().pathFolderDocument}/CEFR_Wordlist/image/$image"),
          fit: fit,
        )
      : Image.asset('assets/no_image.jpg');
}

Widget widgetIcon(String path, {double? size, Color? color}) {
  return SvgPicture.asset(
    path,
    width: size ?? size_icon,
    height: size ?? size_icon,
    color: color,
  );
}
