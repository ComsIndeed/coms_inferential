abstract class WindowState {}

class InitialWindowState extends WindowState {}

class WindowOpenedState extends WindowState {}

class WindowAnimationState extends WindowState {
  final double progress;
  WindowAnimationState(this.progress);
}

class WindowClosedState extends WindowState {}
