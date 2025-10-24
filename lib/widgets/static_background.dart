import 'dart:math';
import 'package:flutter/material.dart';

class StaticBackground extends StatelessWidget {
  const StaticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _StaticPainter(),
      ),
    );
  }
}

class _StaticPainter extends CustomPainter {
  final Random _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pixelSize = 2.0;

    for (double y = 0; y < size.height; y += pixelSize) {
      for (double x = 0; x < size.width; x += pixelSize) {
        paint.color = _random.nextBool() ? Colors.black : Colors.white;
        canvas.drawRect(Rect.fromLTWH(x, y, pixelSize, pixelSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
