import 'package:radiokapp/screens/audio_handler.dart' as local_audio;

/// Simple controller that routes playback commands to the shared [AudioHandler].
class RadioController {
  final local_audio.AudioHandler audioHandler;
  String? currentStationUrl;
  bool isPlaying = false;
  bool _isBusy = false;
  double _volume = 1.0;

  RadioController(this.audioHandler);

  Future<void> play(String url) async {
    if (_isBusy) return;
    _isBusy = true;
    try {
      await audioHandler.stop();
      await audioHandler.setVolume(_volume);
      await audioHandler.setUrl(url);
      await audioHandler.play();
      currentStationUrl = url;
      isPlaying = true;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> stop() async {
    await audioHandler.stop();
    currentStationUrl = null;
    isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await audioHandler.setVolume(_volume);
  }

  double get volume => _volume;
}

