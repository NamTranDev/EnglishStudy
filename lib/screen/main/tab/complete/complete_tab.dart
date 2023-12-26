import 'package:english_study/model/category.dart';
import 'package:english_study/screen/category/category_component.dart';
import 'package:flutter/material.dart';

class CompleteTab extends StatefulWidget {
  const CompleteTab({super.key});

  @override
  State<CompleteTab> createState() => _CompleteTabState();
}

class _CompleteTabState extends State<CompleteTab> {
  @override
  Widget build(BuildContext context) {
    return CategoryComponent(
      onPickCategory: (Category category) {
        
      },
      isComplete: true,
    );
  }
}
