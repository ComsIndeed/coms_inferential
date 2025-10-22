import 'package:flutter/material.dart';

class InputContainer extends StatefulWidget {
  const InputContainer({super.key});

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      width: 700,
      height: 90,
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor.withAlpha(160),
        shape: RoundedSuperellipseBorder(
          side: BorderSide(color: Theme.of(context).cardColor, width: 1),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Coms anything...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
