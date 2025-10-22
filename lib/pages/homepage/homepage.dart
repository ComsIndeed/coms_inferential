import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:coms_inferential/pages/homepage/input_container.dart';
import 'package:coms_inferential/pages/homepage/top_row.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowBloc, WindowState>(
      builder: (context, state) {
        return AnimatedOpacity(
          opacity: state is WindowAnimationState
              ? clampDouble(state.progress * 10, 0, 1)
              : 0,
          duration: Duration.zero,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [TopRow(), InputContainer()],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
