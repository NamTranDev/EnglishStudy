import 'package:english_study/constants.dart';
import 'package:flutter/cupertino.dart';

class RequestGetDataComponent extends StatelessWidget {
  const RequestGetDataComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      color: maastricht_blue.withAlpha(100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You need to download data to study'),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {},
            child: Text('Download'),
          )
        ],
      ),
    );
  }
}
