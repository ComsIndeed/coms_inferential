import 'package:flutter/material.dart';

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 32),
        Text("Coms Inferential", style: Theme.of(context).textTheme.titleLarge),
        Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.fullscreen,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
        ),
        SizedBox(width: 32),
      ],
    );
  }
}
