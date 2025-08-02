import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:radiokapp/screens/audio_handler.dart' as local_audio;
import 'package:radiokapp/screens/now_playing_screen.dart';

class NowPlayingBar extends StatelessWidget {
  final local_audio.AudioHandler audioHandler;
  final String? currentStationName;

  const NowPlayingBar({
    Key? key,
    required this.audioHandler,
    required this.currentStationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

        if (!isPlaying || currentStationName == null) {
          return const SizedBox(); // لا تظهر الشريط إذا لا يوجد بث
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NowPlayingScreen(
                  audioHandler: audioHandler,
                  stationName: currentStationName,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'يتم الآن تشغيل: $currentStationName',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white),
                  onPressed: () => audioHandler.stop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
