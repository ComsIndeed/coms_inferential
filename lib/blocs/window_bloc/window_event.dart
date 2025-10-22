abstract class WindowEvent {}

class OpenWindowEvent extends WindowEvent {}

class CloseWindowEvent extends WindowEvent {}

class NormalizeWindowEvent extends WindowEvent {}

class MaximizeWindowEvent extends WindowEvent {}

class WindowAnimationUpdateEvent extends WindowEvent {
  final double progress;

  WindowAnimationUpdateEvent(this.progress);
}

class WindowOpenCompletedEvent extends WindowEvent {}

class WindowCloseCompletedEvent extends WindowEvent {}
