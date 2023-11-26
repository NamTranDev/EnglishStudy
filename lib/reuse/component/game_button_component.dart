import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class GameButtonComponent extends StatelessWidget {
  final Function onClick;

  const GameButtonComponent({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: maastricht_blue),
      ),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          onClick.call();
        },
        child: widgetIcon('assets/icons/ic_game.svg', color: maastricht_blue),
      ),
    );
  }
}
