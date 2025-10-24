import 'package:coms_inferential/widgets/static_background.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

abstract class WindowEvent {}

class OpenWindowEvent extends WindowEvent {}

class CloseWindowEvent extends WindowEvent {}

class WindowAnimationUpdateEvent extends WindowEvent {
  final double progress;

  WindowAnimationUpdateEvent(this.progress);
}

class WindowOpenCompletedEvent extends WindowEvent {}

class WindowCloseCompletedEvent extends WindowEvent {}

class WindowTransitionEvent extends WindowEvent {
  final WindowEffect effect;
  final Duration duration;
  final Widget background;

  WindowTransitionEvent({
    required this.effect,
    this.duration = const Duration(milliseconds: 200),
    this.background = const StaticBackground(),
  });
}
