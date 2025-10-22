import 'package:coms_inferential/pages/homepage/input_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final AnimationController controller;
  const Homepage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: clampDouble(controller.value * 10, 0, 1),
      duration: Duration.zero,
      child: Scaffold(body: Center(child: InputContainer())),
    );
  }
}
