import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class WidgetAnswer extends StatelessWidget {
  final int typeAnswer;
  final String answer;
  final bool isSpelling;
  final Function onSelect;

  const WidgetAnswer({
    super.key,
    required this.typeAnswer,
    required this.answer,
    required this.onSelect,
    required this.isSpelling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 50,
      ),
      decoration: BoxDecoration(
        color: typeAnswer == 1
            ? Colors.transparent
            : typeAnswer == 2
                ? turquoise
                : ruddy,
        border: Border.all(
          color: maastricht_blue,
          width: typeAnswer == 1 ? 0.5 : 0,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () {
          onSelect.call();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: isSpelling ? 'Noto' : 'Roboto',
                color: typeAnswer == 1 ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }
}
