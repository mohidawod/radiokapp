import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    mediaItem.add(
      MediaItem(
        id: 'https://example.com/stream.mp3',
        album: 'راديو مباشر',
        title: 'قناة البث',
        artist: 'Radio K',
        artUri: Uri.parse('https://via.placeholder.com/150'),
      ),
    );

    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      final processingState = _translateProcessingState(
        _player.processingState,
      );

      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.stop,
            playing ? MediaControl.pause : MediaControl.play,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1],
          playing: playing,
          processingState: processingState,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
        ),
      );
    });
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
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
  }

  Future<void> setUrl(String url) async {
    try {
      await _player.setUrl(url);
      mediaItem.add(
        MediaItem(
          id: url,
          album: 'راديو مباشر',
          title: 'قناة البث',
          artist: 'Radio K',
          artUri: Uri.parse('https://via.placeholder.com/150'),
        ),
      );
    } catch (e) {
      print('حدث خطأ أثناء تحميل البث: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('تعذر ضبط مستوى الصوت: $e');
    }
  }
}
