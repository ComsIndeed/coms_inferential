import 'package:coms_inferential/pages/homepage/homepage.dart';
import 'package:coms_inferential/providers/window_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  await windowManager.ensureInitialized();
  await Window.initialize();

  var windowOptions = const WindowOptions(
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

  runApp(
    ChangeNotifierProvider(
      create: (_) => WindowProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<WindowProvider>(context, listen: false).initialize(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const Homepage(),
    );
  }
}
