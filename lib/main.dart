import 'dart:io';

import 'package:coms_inferential/blocs/chat_history_bloc/chat_history_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_bloc.dart';
import 'package:coms_inferential/blocs/chat_session_bloc/chat_session_event.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_bloc.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_state.dart';
import 'package:coms_inferential/blocs/window_bloc/window_bloc.dart';
import 'package:coms_inferential/pages/homepage/homepage.dart';
import 'package:coms_inferential/pages/settings/settings_page.dart';
import 'package:coms_inferential/services/chat_history_service.dart';
import 'package:coms_inferential/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hotKeyManager.unregisterAll();
  await windowManager.ensureInitialized();
  await Window.initialize();

  // ADD THIS BLOCK
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
        Window.setEffect(effect: WindowEffect.acrylic, color: Colors.black);
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
  late final ChatHistoryService _chatHistoryService;
  late final GeminiService _geminiService;
  late final ChatSessionBloc _chatSessionBloc;
  late final ChatHistoryBloc _chatHistoryBloc;

  @override
  void initState() {
    super.initState();
    _windowBloc = WindowBloc(this);
    _settingsBloc = SettingsBloc();
    _chatHistoryService = ChatHistoryService();
    _geminiService = GeminiService();
    _chatSessionBloc = ChatSessionBloc(
      chatHistoryService: _chatHistoryService,
      geminiService: _geminiService,
    );
    _chatHistoryBloc = ChatHistoryBloc(chatHistoryService: _chatHistoryService);

    _chatSessionBloc.add(const StartNewChat());
    _chatHistoryBloc.add(const LoadAllChats());
  }

  @override
  void dispose() {
    _chatSessionBloc.close();
    _chatHistoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _windowBloc),
        BlocProvider.value(value: _settingsBloc),
        BlocProvider.value(value: _chatSessionBloc),
        BlocProvider.value(value: _chatHistoryBloc),
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
