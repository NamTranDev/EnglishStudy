import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeaderTitleComponent extends StatelessWidget {
  final String? title;

  const HeaderTitleComponent({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      constraints: BoxConstraints(
        minHeight: 50,
      ),
      alignment: Alignment.center,
      child: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style:
            Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
      ),
    );
  }
}
