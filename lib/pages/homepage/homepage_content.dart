import 'package:coms_inferential/pages/homepage/top_row.dart';
import 'package:coms_inferential/widgets/chat_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomepageContent extends StatelessWidget {
  const HomepageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TopRow(),
            const SizedBox(height: 16),
            const ChatInput().animate().fadeIn().slideY(
              begin: 0.375,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeInOutCubicEmphasized,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
