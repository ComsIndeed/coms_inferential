import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_event.dart';
import 'package:coms_inferential/blocs/settings_bloc/settings_state.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsHidden()) {
    on<ShowSettings>((event, emit) async {
      await windowManager.unmaximize();
      await Window.setEffect(effect: WindowEffect.disabled);
      emit(SettingsVisible());
    });

    on<HideSettings>((event, emit) async {
      await windowManager.maximize();
      await Window.setEffect(effect: WindowEffect.acrylic);
      emit(SettingsHidden());
    });
  }
}
