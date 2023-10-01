import 'package:flutter/material.dart';

class DragFillAnswerComponent extends StatefulWidget {
  const DragFillAnswerComponent({super.key});

  @override
  State<DragFillAnswerComponent> createState() => _DragFillAnswerComponentState();
}

class _DragFillAnswerComponentState extends State<DragFillAnswerComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('DragFillAnswer'),
      ),
    );
  }
}