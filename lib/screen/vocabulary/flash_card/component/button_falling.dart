import 'package:english_study/constants.dart';
import 'package:flutter/material.dart';

class ButtonFalling extends StatefulWidget {
  final Widget child;
  final Function? onAnimationComplete;
  ButtonFalling({Key? key, required this.child, this.onAnimationComplete})
      : super(key: key);
  @override
  _ButtonFallingState createState() => _ButtonFallingState();
}

class _ButtonFallingState extends State<ButtonFalling>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          child: Container(
            width: 2,
            height: 20,
            color: turquoise,
          ),
        ),
        widget.child
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
