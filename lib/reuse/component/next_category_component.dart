import 'package:english_study/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextCategoryComponent extends StatelessWidget {
  final String text;
  final Function onNextCategoryClick;
  const NextCategoryComponent(
      {super.key, required this.text, required this.onNextCategoryClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.only(left: 8, right: 8),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: maastricht_blue),
                ),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    onNextCategoryClick.call();
                  },
                  child: widgetIcon(
                    'assets/icons/ic_arrow_next.svg',
                    size: 28,
                    color: maastricht_blue,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
