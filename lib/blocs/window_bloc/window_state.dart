abstract class WindowState {
  final bool isVisible;

  const WindowState({this.isVisible = false});
}

class InitialWindowState extends WindowState {}

class WindowAnimationState extends WindowState {
  final double progress;

  const WindowAnimationState(this.progress, {required super.isVisible});
}

class WindowOpenedState extends WindowState {
  WindowOpenedState() : super(isVisible: true);
}

class WindowClosedState extends WindowState {
  WindowClosedState() : super(isVisible: false);
}
