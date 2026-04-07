import 'package:flutter/material.dart';
import 'package:radiokapp/repositories/radio_repository.dart';
import 'package:radiokapp/services/audio_player_service.dart';
import 'package:radiokapp/services/preferences_service.dart';
import 'package:radiokapp/services/radio_api_service.dart';
import 'package:radiokapp/view/main_view.dart';
import 'package:radiokapp/view/screens/welcome_screen.dart';
import 'package:radiokapp/view/theme/app_theme.dart';
import 'package:radiokapp/viewmodels/radio_viewmodel.dart';

class RadioKApp extends StatefulWidget {
  const RadioKApp({super.key});

  @override
  State<RadioKApp> createState() => _RadioKAppState();
}

class _RadioKAppState extends State<RadioKApp> {
  late final RadioViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RadioViewModel(
      repository: RadioRepository(
        apiService: RadioApiService(),
        preferencesService: PreferencesService(),
      ),
      audioPlayerService: AudioPlayerService(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _viewModel.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: WelcomeScreen(viewModel: _viewModel),
          routes: {
            MainView.routeName: (_) => MainView(viewModel: _viewModel),
          },
        );
      },
    );
  }
}
