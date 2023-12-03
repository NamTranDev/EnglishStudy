import 'dart:io';
import 'dart:math';

import 'package:english_study/storage/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

const Color color_primary = Color(0xFF2E4B5C);

const Color maastricht_blue = Color(0xFF011627);
const Color ruddy = Color(0xFFF89292);
const Color turquoise = Color(0xFF6DD2A0);
const Color baby_powder = Color(0xFFFDFFFC);
const Color red_violet = Color(0xFFB91372);
const Color yellow = Color(0xFFE9D502);

const Color disable = Color.fromARGB(255, 215, 215, 198);

const int duration_animation_screen = 300;
const int duration_animation_right_wrong = 200;
const int duration_animation_next = 300;
const double size_icon = 30;

ThemeData themeInfo = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  cardTheme: CardTheme(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
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

Widget widgetImage(String? folderName, String? image, {BoxFit? fit}) {
  return image != null
      ? loadImage(folderName, image, fit: fit)
      : Image.asset('assets/no_image.jpg');
}

Widget loadImage(String? folderName, String image, {BoxFit? fit}) {
  var path =
      "${getIt<AppMemory>().pathFolderDocument}/${getIt<Preference>().currentCategory()}/${folderName}/image/$image";
  var file = File(path);
  var fileExist = file.existsSync();

  if (fileExist) {
    return Image.file(
      file,
      fit: fit,
    );
  }

  var pathAsset = 'assets/image/$image';
  return FutureBuilder<bool>(
    future: doesImageExistInAssets(pathAsset),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.data == true) {
          return Image.asset(
            pathAsset,
            fit: fit,
          );
        } else {
          return Image.asset('assets/no_image.jpg', fit: fit);
        }
      } else {
        // While waiting for the future, you can return a placeholder or loading indicator.
        return CircularProgressIndicator();
      }
    },
  );
}

Widget widgetIcon(String path, {double? size, Color? color, BoxFit? fit}) {
  return SvgPicture.asset(
    path,
    width: size ?? size_icon,
    height: size ?? size_icon,
    color: color,
    fit: fit ?? BoxFit.contain,
  );
}

void showSnackBar(BuildContext context, String text,
    {String? iconSvg, Color? iconSvgColor}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    elevation: 0,
    duration: const Duration(milliseconds: 2000),
    content: Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            widgetIcon(iconSvg ?? 'assets/icons/ic_warning.svg',
                color: iconSvgColor ?? yellow, size: 32),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(snackBar)
      .closed
      .then((value) => ScaffoldMessenger.of(context).clearSnackBars());
  ;
}
