import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:coms_inferential/pages/homepage/homepage_content.dart';
import 'package:coms_inferential/pages/homepage/static_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowBloc, WindowState>(
      builder: (context, state) {
        final opacity = state is WindowAnimationState
            ? clampDouble(state.progress * 10, 0, 1)
            : state.isVisible
            ? 1.0
            : 0.0;
        return AnimatedOpacity(
          opacity: opacity,
          duration: Duration.zero,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                StaticView(showStatic: state.showStatic),
                if (state.isVisible) HomepageContent(),
              ],
            ),
          ),
        );
      },
    );
  }
}
