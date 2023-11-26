import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class BackScreenComponent extends StatelessWidget {
  final Widget child;
  final String? icon_asset;
  final double? margin_top;
  final double? margin_left;
  const BackScreenComponent(
      {super.key,
      required this.child,
      this.icon_asset,
      this.margin_top,
      this.margin_left});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: margin_top ?? 10,
          left: margin_left ?? 10,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: widgetIcon(icon_asset ?? 'assets/icons/ic_arrow_prev.svg',
                size: 32, fit: BoxFit.fitHeight),
          ),
        ),
      ],
    );
  }
}
