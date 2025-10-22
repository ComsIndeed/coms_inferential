import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:coms_inferential/pages/homepage/input_container.dart';
import 'package:coms_inferential/pages/homepage/top_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowBloc, WindowState>(
      builder: (context, state) {
        final opacity = state is WindowAnimationState
            ? clampDouble(state.progress * 100, 0, 1)
            : state.isVisible
            ? 1.0
            : 0.0;
        return AnimatedOpacity(
          opacity: opacity,
          duration: Duration.zero,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isVisible) TopRow(),
                    if (state.isVisible)
                      InputContainer().animate().fadeIn().slideY(
                        begin: 0.375,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeInOutCubicEmphasized,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
