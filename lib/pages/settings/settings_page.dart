import 'package:coms_inferential/blocs/settings_bloc/settings_bloc.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<SettingsBloc>().add(HideSettings());
          },
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
            subtitle: Text('Change the application theme'),
          ),
          ListTile(
            leading: Icon(Icons.keyboard),
            title: Text('Hotkeys'),
            subtitle: Text('Configure global hotkeys'),
          ),
          ListTile(
            leading: Icon(Icons.settings_ethernet),
            title: Text('Model Settings'),
            subtitle: Text('Adjust AI model parameters'),
          ),
        ],
      ),
    );
  }
}
