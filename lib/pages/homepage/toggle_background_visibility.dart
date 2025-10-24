import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_event.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleBackgroundVisibility extends StatelessWidget {
  const ToggleBackgroundVisibility({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowBloc, WindowState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => context.read<WindowBloc>().add(
            WindowTransitionEvent(
              effect:
                  context.read<WindowBloc>().currentEffect ==
                      WindowEffect.acrylic
                  ? WindowEffect.transparent
                  : WindowEffect.acrylic,
            ),
          ),
          icon: Icon(
            context.read<WindowBloc>().currentEffect == WindowEffect.acrylic
                ? Icons.remove_red_eye_outlined
                : Icons.remove_red_eye,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
        );
      },
    );
  }
}
