import 'package:coms_inferential/pages/homepage/input_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isWindowVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _controller.addListener(() {
      windowManager.setOpacity(_controller.value);
      setState(() {});
    });

    _registerHotKey();
  }

  @override
  void dispose() {
    _controller.dispose();
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  void _registerHotKey() async {
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) => _toggleWindow(),
    );
  }

  void _toggleWindow() async {
    if (_isWindowVisible) {
      await _controller.reverse();
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
      await _controller.forward();
    }
    _isWindowVisible = !_isWindowVisible;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: clampDouble(_controller.value * 10, 0, 1),
      duration: Duration.zero,
      child: Scaffold(body: Center(child: InputContainer())),
    );
  }
}
