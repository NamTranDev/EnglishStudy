import 'package:flutter/material.dart';

class CompleteTab extends StatefulWidget {
  const CompleteTab({super.key});

  @override
  State<CompleteTab> createState() => _CompleteTabState();
}

class _CompleteTabState extends State<CompleteTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Complete Tab'),
      ),
    );
  }
}