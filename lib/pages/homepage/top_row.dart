import 'package:coms_inferential/blocs/settings_bloc/settings_bloc.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 32),
        Text("Coms Inferential", style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.fullscreen,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
        ),
        IconButton(
          onPressed: () {
            context.read<SettingsBloc>().add(ShowSettings());
          },
          icon: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
        ),
        const SizedBox(width: 32),
      ].animate(interval: Durations.short1).fadeIn(duration: Durations.short4),
    );
  }
}
