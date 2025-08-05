import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'screens/audio_handler.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final audioHandler = await AudioService.init(
    builder: () => AudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.radiokapp.audio',
      androidNotificationChannelName: 'Radio Playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatefulWidget {
  final AudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
        audioHandler: widget.audioHandler,
      ),
    );
  }
}
