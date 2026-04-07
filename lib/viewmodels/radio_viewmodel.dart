import 'package:flutter/material.dart';
import 'package:radiokapp/models/radio_station.dart';
import 'package:radiokapp/repositories/radio_repository.dart';
import 'package:radiokapp/services/audio_player_service.dart';

class RadioViewModel extends ChangeNotifier {
  final RadioRepository _repository;
  final AudioPlayerService _audioPlayerService;

  RadioViewModel({
    required RadioRepository repository,
    required AudioPlayerService audioPlayerService,
  }) : _repository = repository,
       _audioPlayerService = audioPlayerService;

  List<RadioStation> _stations = [];
  bool _isDarkMode = false;
  bool _isLoading = true;
  int _currentIndex = 0;
  double _currentVolume = 1.0;
  String? _currentStationUrl;
  String? _errorMessage;
  String? _nowPlaying;

  List<RadioStation> get stations => List.unmodifiable(_stations);
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  double get currentVolume => _currentVolume;
  String? get currentStationUrl => _currentStationUrl;
  String? get errorMessage => _errorMessage;
  String? get nowPlaying => _nowPlaying;

  List<RadioStation> get favoriteStations =>
      _stations.where((station) => station.isFavorite).toList();

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isDarkMode = await _repository.getDarkMode();
      _stations = await _repository.getStations();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل تحميل المحطات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playStation(RadioStation station) async {
    try {
      await _audioPlayerService.play(station.url, volume: _currentVolume);
      _currentStationUrl = station.url;
      _nowPlaying = station.name;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'فشل تشغيل المحطة: $e';
      _nowPlaying = null;
      _currentStationUrl = null;
      notifyListeners();
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayerService.stop();
    _currentStationUrl = null;
    _nowPlaying = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(RadioStation station) async {
    station.isFavorite = !station.isFavorite;
    await _repository.saveFavorites(_stations);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _repository.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> changeVolume(double volume) async {
    _currentVolume = volume;
    await _audioPlayerService.setVolume(volume);
    notifyListeners();
  }

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }
}
