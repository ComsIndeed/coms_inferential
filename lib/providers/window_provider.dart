import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class WindowProvider with ChangeNotifier {
  late final AnimationController _controller;
  bool _isWindowVisible = false;

  Animation<double> get animation => _controller.view;

  void initialize(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 50),
    );

    _controller.addListener(() {
      windowManager.setOpacity(_controller.value);
      notifyListeners();
    });

    _registerHotKey();
  }

  void _registerHotKey() async {
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    );

    await hotKeyManager.register(hotKey, keyDownHandler: (_) => toggleWindow());
  }

  Future<void> toggleWindow() async {
    if (_isWindowVisible) {
      await _controller.reverse();
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
      await _controller.forward();
    }
    _isWindowVisible = !_isWindowVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    hotKeyManager.unregisterAll();
    super.dispose();
  }
}
