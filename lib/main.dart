import 'package:coms_inferential/blocs/settings_bloc/settings_bloc.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_state.dart';
import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/pages/homepage/homepage.dart';
import 'package:coms_inferential/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
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

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  late final WindowBloc _windowBloc;
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _windowBloc = WindowBloc(this);
    _settingsBloc = SettingsBloc();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _windowBloc),
        BlocProvider.value(value: _settingsBloc),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsVisible) {
              return const SettingsPage();
            }
            return const Homepage();
          },
        ),
      ),
    );
  }
}
