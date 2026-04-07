import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player;
  bool _isBusy = false;
  String? _currentUrl;
  int _operationId = 0;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _player.setVolume(1.0);
  }

  bool get isBusy => _isBusy;

  Future<void> play(String url, {double volume = 1.0}) async {
    final operationId = ++_operationId;
    _isBusy = true;

    try {
      if (_player.playing && _currentUrl == url) {
        await _player.setVolume(volume);
        return;
      }

      await _player.setVolume(volume);

      if (_currentUrl != url) {
        await _player.stop();
        await _player.setUrl(url);
        _currentUrl = url;
      }

      if (operationId != _operationId) {
        return;
      }

      await _player.play();
    } finally {
      if (operationId == _operationId) {
        _isBusy = false;
      }
    }
  }

  Future<void> stop() async {
    final operationId = ++_operationId;
    _isBusy = true;

    try {
      await _player.stop();
      if (operationId == _operationId) {
        _currentUrl = null;
      }
    } finally {
      if (operationId == _operationId) {
        _isBusy = false;
      }
    }
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
