import 'package:coms_inferential/pages/homepage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  await windowManager.ensureInitialized();
  await Window.initialize();

  var windowOptions = WindowOptions(
    center: true,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    fullScreen: true,
  );

  windowManager
      .waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setOpacity(0.0);
      })
      .then((_) {
        Window.setEffect(
          effect: WindowEffect.acrylic,
          // dark: true,
          color: Colors.black,
        );
      });

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
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
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Homepage(controller: _controller),
    );
  }
}
