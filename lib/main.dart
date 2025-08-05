import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radiokapp/screens/audio_handler.dart' as local_audio;
import 'package:radiokapp/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => local_audio.AudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.radiokapp.channel.audio',
      androidNotificationChannelName: 'Radio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatefulWidget {
  final local_audio.AudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = _prefs.getBool('darkMode') ?? false;
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _prefs.setBool('darkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
        audioHandler: widget.audioHandler,
      ),
    );
  }
}

