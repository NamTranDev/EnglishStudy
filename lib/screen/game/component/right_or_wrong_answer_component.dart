import 'package:flutter/material.dart';

class RightOrWrongAnswerComponent extends StatefulWidget {
  const RightOrWrongAnswerComponent({super.key});

  @override
  State<RightOrWrongAnswerComponent> createState() => _RightOrWrongAnswerComponentState();
}

class _RightOrWrongAnswerComponentState extends State<RightOrWrongAnswerComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('RightOrWrongAnswer'),
      ),
    );
  }
}