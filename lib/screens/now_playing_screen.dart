import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:radiokapp/screens/audio_handler.dart' as local_audio;

class NowPlayingScreen extends StatefulWidget {
  final local_audio.AudioHandler audioHandler;
  final String? stationName;

  const NowPlayingScreen({
    Key? key,
    required this.audioHandler,
    required this.stationName,
  }) : super(key: key);

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
    });
    widget.audioHandler.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تشغيل المحطة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio, size: 100, color: Colors.blue.shade700),
            const SizedBox(height: 30),
            Text(
              widget.stationName ?? 'لا يوجد محطة حالياً',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            StreamBuilder<PlaybackState>(
              stream: widget.audioHandler.playbackState,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? false;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: IconButton(
                    key: ValueKey(isPlaying),
                    iconSize: 64,
                    icon: Icon(
                      isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        widget.audioHandler.stop();
                      } else {
                        widget.audioHandler.play();
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                const Text('الصوت'),
                Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: _setVolume,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
