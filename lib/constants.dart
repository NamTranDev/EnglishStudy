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

const Color sky_blue = Color(0xFFcee4ea);
const Color maastricht_blue = Color(0xFF011627);
const Color ruddy = Color(0xFFF89292);
const Color turquoise = Color.fromRGBO(109, 210, 160, 1);
const Color baby_powder = Color(0xFFFDFFFC);
const Color red_violet = Color(0xFFB91372);
const Color yellow = Color(0xFFE9D502);

const Color disable = Color.fromARGB(255, 215, 215, 198);

const int duration_animation_screen = 300;
const int duration_animation_right_wrong = 200;
const int duration_animation_next = 300;
const int duration_animation_visible = 500;
const double size_icon = 30;

const String URL_UPDATE =
    'https://dl.dropboxusercontent.com/scl/fi/29cx8416xfxaqusjljwow/update.json?rlkey=dq67zt08e69d6csbjnnuc2yzv&dl=0';

ThemeData themeInfo = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  cardTheme: CardTheme(
    color: Colors.white,
    surfaceTintColor: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 30,
      color: maastricht_blue,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: maastricht_blue,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
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

Widget widgetImage(String? image_name, String? image_path, {BoxFit? fit}) {
  return image_name != null
      ? loadImage(image_name, image_path, fit: fit)
      : Image.asset('assets/no_image.jpg');
}

Widget widgetImageAsset(String? image_name, {BoxFit? fit}) {
  var pathAsset = 'assets/image/$image_name';
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

Widget loadImage(String? image_name, String? image_path, {BoxFit? fit}) {
  var file = File('${getIt<AppMemory>().pathFolderDocument}/$image_path');
  var fileExist = file.existsSync();

  if (fileExist) {
    return Image.file(
      file,
      fit: fit,
    );
  }

  return widgetImageAsset(image_name, fit: fit);
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
