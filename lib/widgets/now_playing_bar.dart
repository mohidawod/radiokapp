import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:radiokapp/screens/audio_handler.dart' as local_audio;
import 'package:radiokapp/screens/now_playing_screen.dart';

class NowPlayingBar extends StatelessWidget {
  final local_audio.AudioHandler audioHandler;

  const NowPlayingBar({
    super.key,
    required this.audioHandler,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, stateSnapshot) {
            final isPlaying = stateSnapshot.data?.playing ?? false;

            if (!isPlaying || mediaItem == null) {
              return const SizedBox();
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NowPlayingScreen(
                      audioHandler: audioHandler,
                      stationName: mediaItem.title,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        'يتم الآن تشغيل: ${mediaItem.title}',
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
      },
    );
  }
}
