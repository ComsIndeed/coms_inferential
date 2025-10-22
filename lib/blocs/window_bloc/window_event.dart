abstract class WindowEvent {}

class WindowAnimationUpdateEvent extends WindowEvent {
  final double progress;
  WindowAnimationUpdateEvent(this.progress);
}

class OpenWindowEvent extends WindowEvent {}

class CloseWindowEvent extends WindowEvent {}

class NormalizeWindowEvent extends WindowEvent {}

class MaximizeWindowEvent extends WindowEvent {}
