import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart' as audio_service;

import 'screens/audio_handler.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await audio_service.AudioService.init<AudioHandler>(
    builder: () => AudioHandler(),
    config: const audio_service.AudioServiceConfig(
      androidNotificationChannelId: 'com.radiokapp.channel.audio',
      androidNotificationChannelName: 'Radio Playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: handler));
}

class MyApp extends StatefulWidget {
  final AudioHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
        audioHandler: widget.audioHandler,
      ),
    );
  }
}
