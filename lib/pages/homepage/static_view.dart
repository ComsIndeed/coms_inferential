import 'package:flutter/material.dart';

class StaticView extends StatelessWidget {
  const StaticView({super.key, required this.showStatic});

  final bool showStatic;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showStatic ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox.expand(
        child: Container(
          color: HSLColor.fromColor(
            Theme.of(context).colorScheme.surface,
          ).withLightness(0.4).toColor(),
        ),
      ),
    );
  }
}
