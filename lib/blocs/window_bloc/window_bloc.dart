import 'dart:ui';

import 'package:coms_inferential/blocs/window_bloc/window_event.dart';
import 'package:coms_inferential/blocs/window_bloc/window_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

class WindowBloc extends Bloc<WindowEvent, WindowState> {
  late final AnimationController _controller;
  Animation<double> get animation => _controller.view;
  bool _isWindowVisible = false;
  WindowEffect _currentEffect = WindowEffect.acrylic;
  WindowEffect get currentEffect => _currentEffect;

  WindowBloc(TickerProvider vsync) : super(InitialWindowState()) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );

    _controller.addListener(() async {
      await windowManager.setOpacity(_controller.value);
      add(WindowAnimationUpdateEvent(_controller.value));
    });

    on<OpenWindowEvent>((event, emit) async {
      _isWindowVisible = true;
      await windowManager.show();
      await windowManager.focus();
      await _controller.forward();
      emit(WindowOpenedState());
    });

    on<CloseWindowEvent>((event, emit) async {
      _isWindowVisible = false;
      await _controller.reverse();
      await windowManager.hide();
      emit(WindowClosedState());
    });

    on<WindowAnimationUpdateEvent>((event, emit) {
      emit(WindowAnimationState(event.progress, isVisible: _isWindowVisible));
    });

    on<WindowTransitionEvent>((event, emit) async {
      if (event.effect == currentEffect) return;
      final halfDuration = event.duration ~/ 2;

      emit(
        WindowAnimationState(
          1,
          isVisible: true,
          showStatic: true,
          currentEffect: _currentEffect,
        ),
      );
      await Future.delayed(halfDuration);
      await Window.setEffect(effect: event.effect, color: Colors.transparent);
      _currentEffect = event.effect;
      await Future.delayed(halfDuration);
      emit(
        WindowAnimationState(
          1,
          isVisible: true,
          showStatic: false,
          currentEffect: _currentEffect,
        ),
      );
    });

    _registerHotKey();
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
      },
    );
  }
}
