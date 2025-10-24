import 'package:flutter_acrylic/window_effect.dart';

abstract class WindowState {
  final bool isVisible;
  final bool showStatic;
  final WindowEffect currentEffect;

  const WindowState({
    this.isVisible = false,
    this.showStatic = false,
    this.currentEffect = WindowEffect.acrylic,
  });
}

class InitialWindowState extends WindowState {}

class WindowAnimationState extends WindowState {
  final double progress;

  const WindowAnimationState(
    this.progress, {
    super.isVisible,
    super.currentEffect,
    super.showStatic = false,
  });
}

class WindowOpenedState extends WindowState {
  final bool isBefore;
  WindowOpenedState({this.isBefore = false}) : super(isVisible: true);
}

class WindowClosedState extends WindowState {
  WindowClosedState() : super(isVisible: false);
}
