import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:radiokapp/screens/audio_handler.dart' as local_audio;
import 'package:radiokapp/screens/now_playing_screen.dart';

class NowPlayingBar extends StatefulWidget {
  final local_audio.AudioHandler audioHandler;
  final String? currentStationName;

  const NowPlayingBar({
    Key? key,
    required this.audioHandler,
    required this.currentStationName,
  }) : super(key: key);

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  late StreamSubscription<PlaybackState> _subscription;
  bool _showBar = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.audioHandler.playbackState.listen((state) {
      final playing = state.playing;
      if (playing) {
        if (!_showBar) {
          setState(() {
            _showBar = true;
            _isVisible = false;
          });
          // Trigger the slide-in animation in the next frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _isVisible = true);
            }
          });
        } else {
          setState(() => _isVisible = true);
        }
      } else {
        setState(() => _isVisible = false);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isVisible) {
            setState(() => _showBar = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBar ||
        widget.currentStationName == null ||
        widget.currentStationName!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _isVisible ? Offset.zero : const Offset(0, 1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NowPlayingScreen(
                audioHandler: widget.audioHandler,
                stationName: widget.currentStationName,
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
                  'يتم الآن تشغيل: ${widget.currentStationName}',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: () => widget.audioHandler.stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
