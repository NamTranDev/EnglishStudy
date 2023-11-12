import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class BackScreenComponent extends StatelessWidget {
  final Widget child;
  const BackScreenComponent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 10,
          left: 10,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: widgetIcon('assets/icons/ic_arrow_prev.svg'),
          ),
        ),
      ],
    );
  }
}
