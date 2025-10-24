import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InputContainer extends StatefulWidget {
  const InputContainer({super.key});

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WindowBloc, WindowState>(
      listener: (context, state) {
        if (state is WindowOpenedState) {
          print("object");
          _focusNode.requestFocus();
        }
      },
      child: Container(
        width: 700,
        height: 90,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.lightBlueAccent, width: 1),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Ask Coms anything...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
