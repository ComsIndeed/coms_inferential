import 'package:coms_inferential/pages/homepage/input_container.dart';
import 'package:coms_inferential/providers/window_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WindowProvider>(
      builder: (context, window, child) {
        return AnimatedOpacity(
          opacity: clampDouble(window.animation.value * 10, 0, 1),
          duration: Duration.zero,
          child: const Scaffold(body: Center(child: InputContainer())),
        );
      },
    );
  }
}
