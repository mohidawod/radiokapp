import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class RadioController {
  final AudioPlayer _player = AudioPlayer();
  String? currentStationUrl;
  bool isPlaying = false;
  bool _isBusy = false;
  double _volume = 1.0;

  RadioController() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _player.playbackEventStream.listen((event) {
      isPlaying = _player.playing;
      if (!isPlaying) {
        currentStationUrl = null;
      }
      // إشعار الواجهة إن أردت باستخدام Provider أو ChangeNotifier
    });
  }

  Future<void> play(String url) async {
    if (_isBusy) return;
    _isBusy = true;
    try {
      if (_player.playing) {
        await _player.stop();
      }

      await _player.setVolume(_volume);
      await _player.setUrl(url);
      await _player.play();

      // تحديث إشعار الخلفية
      AudioServiceBackground.setMediaItem(
        MediaItem(
          id: url,
          title: 'إذاعة مباشرة',
          artist: 'Radio K',
          artUri: Uri.parse('https://via.placeholder.com/150'),
        ),
      );

      currentStationUrl = url;
    } catch (e) {
      print('Error playing stream: $e');
      await stop();
      rethrow;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> stop() async {
    if (_player.playing) {
      await _player.stop();
    }
    currentStationUrl = null;
    isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  double get volume => _volume;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
