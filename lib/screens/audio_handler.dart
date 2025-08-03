import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// مسؤول عن إدارة تشغيل الصوت ونشر الحالة لإظهار إشعارات التحكم.
class AudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  /// تحميل عنوان البث وتعيين معلوماته لظهور في الإشعار.
  Future<void> setUrl(String url, {String title = 'قناة البث'}) async {
    try {
      await _player.setUrl(url);
      mediaItem.add(
        MediaItem(
          id: url,
          album: 'راديو مباشر',
          title: title,
          artist: 'Radio K',
          artUri: Uri.parse('https://via.placeholder.com/150'),
        ),
      );
    } catch (e) {
      print('حدث خطأ أثناء تحميل البث: $e');
    }
  }

  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(
      PlaybackState(
        controls: [
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1],
        playing: playing,
        processingState: _translateProcessingState(_player.processingState),
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  AudioProcessingState _translateProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
    _broadcastState();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _broadcastState();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _broadcastState();
    mediaItem.add(null);
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('تعذر ضبط مستوى الصوت: $e');
    }
  }
}

