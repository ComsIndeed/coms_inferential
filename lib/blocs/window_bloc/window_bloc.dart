import 'dart:ui';

import 'package:coms_inferential/blocs/window_bloc/window_event.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class WindowBloc extends Bloc<WindowEvent, WindowState> {
  late final AnimationController _controller;
  Animation<double> get animation => _controller.view;
  bool _isWindowVisible = false;

  WindowBloc(TickerProvider vsync) : super(InitialWindowState()) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );

    _controller.addListener(() async {
      await windowManager.setOpacity(_controller.value);
      add(WindowAnimationUpdateEvent(_controller.value));
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        add(WindowOpenCompletedEvent());
      } else if (status == AnimationStatus.dismissed) {
        add(WindowCloseCompletedEvent());
      }
    });

    _registerHotKey();

    on<WindowAnimationUpdateEvent>((event, emit) {
      emit(WindowAnimationState(event.progress, isVisible: _isWindowVisible));
    });
    on<OpenWindowEvent>((event, emit) async {
      _isWindowVisible = true;
      await windowManager.show();
      await windowManager.focus();
      await _controller.forward();
    });
    on<CloseWindowEvent>((event, emit) async {
      _isWindowVisible = false;
      await _controller.reverse();
      await windowManager.hide();
    });
    on<WindowOpenCompletedEvent>((event, emit) {
      emit(WindowOpenedState());
    });
    on<WindowCloseCompletedEvent>((event, emit) {
      emit(WindowClosedState());
    });
    on<NormalizeWindowEvent>((event, emit) {
      // Handle normalize window event
    });
    on<MaximizeWindowEvent>((event, emit) {
      // Handle maximize window event
    });
  }

  void _registerHotKey() async {
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) {
        if (_isWindowVisible) {
          add(CloseWindowEvent());
        } else {
          add(OpenWindowEvent());
        }
        _isWindowVisible = !_isWindowVisible;
      },
    );
  }
}
