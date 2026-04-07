import 'package:flutter/material.dart';
import 'package:radiokapp/repositories/radio_repository.dart';
import 'package:radiokapp/services/audio_player_service.dart';
import 'package:radiokapp/services/preferences_service.dart';
import 'package:radiokapp/services/radio_api_service.dart';
import 'package:radiokapp/view/main_view.dart';
import 'package:radiokapp/view/screens/welcome_screen.dart';
import 'package:radiokapp/viewmodels/radio_viewmodel.dart';

class RadioKApp extends StatelessWidget {
  const RadioKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
      routes: {
        MainView.routeName: (_) {
          final viewModel = RadioViewModel(
            repository: RadioRepository(
              apiService: RadioApiService(),
              preferencesService: PreferencesService(),
            ),
            audioPlayerService: AudioPlayerService(),
          );
          return MainView(viewModel: viewModel);
        },
      },
    );
  }
}
