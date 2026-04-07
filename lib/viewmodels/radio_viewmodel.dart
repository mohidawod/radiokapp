import 'dart:async';

import 'package:flutter/material.dart';
import 'package:radiokapp/models/radio_station.dart';
import 'package:radiokapp/repositories/radio_repository.dart';
import 'package:radiokapp/services/audio_player_service.dart';

class RadioViewModel extends ChangeNotifier {
  final RadioRepository _repository;
  final AudioPlayerService _audioPlayerService;
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.light,
  );

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
  String? _transitioningStationUrl;
  String? _errorMessage;
  String? _nowPlaying;
  bool _isRefreshing = false;
  bool _isPlayerBusy = false;
  String _searchQuery = '';
  String _selectedCountry = 'الكل';
  Timer? _searchDebounce;
  RadioStation? _queuedStation;
  bool _queuedStop = false;
  List<String> _availableCountries = ['الكل'];
  List<RadioStation> _filteredStations = [];
  List<RadioStation> _favoriteStations = [];

  List<RadioStation> get stations => List.unmodifiable(_stations);
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isPlayerBusy => _isPlayerBusy;
  int get currentIndex => _currentIndex;
  double get currentVolume => _currentVolume;
  String? get currentStationUrl => _currentStationUrl;
  String? get transitioningStationUrl => _transitioningStationUrl;
  String? get errorMessage => _errorMessage;
  String? get nowPlaying => _nowPlaying;
  String get searchQuery => _searchQuery;
  String get selectedCountry => _selectedCountry;

  List<String> get availableCountries => List.unmodifiable(_availableCountries);

  List<RadioStation> get filteredStations => List.unmodifiable(_filteredStations);

  List<RadioStation> get favoriteStations => List.unmodifiable(_favoriteStations);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isDarkMode = await _repository.getDarkMode();
      themeModeNotifier.value =
          _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      final cachedStations = await _repository.getCachedStations();
      final isCacheFresh = await _repository.isCacheFresh();
      if (cachedStations.isNotEmpty) {
        _stations = cachedStations;
        _recomputeDerivedState();
        _isLoading = false;
        notifyListeners();
        if (!isCacheFresh) {
          unawaited(refreshStations());
        }
        return;
      }

      _stations = await _repository.getPriorityStations();
      _recomputeDerivedState();
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      unawaited(refreshStations());
    } catch (e) {
      _errorMessage = 'فشل تحميل المحطات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStations() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      _stations = await _repository.getStations();
      _recomputeDerivedState();
      _errorMessage = null;
    } catch (e) {
      if (_stations.isEmpty) {
        _errorMessage = 'فشل تحميل المحطات: $e';
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> playStation(RadioStation station) async {
    _queuedStop = false;
    _queuedStation = station;
    _transitioningStationUrl = station.url;
    _currentStationUrl = station.url;
    _nowPlaying = station.name;
    _errorMessage = null;
    notifyListeners();

    if (_isPlayerBusy) {
      return;
    }

    await _drainPlaybackQueue();
  }

  Future<void> stopPlaying() async {
    _queuedStation = null;
    _queuedStop = true;
    _transitioningStationUrl ??= _currentStationUrl;
    _currentStationUrl = null;
    _nowPlaying = null;
    notifyListeners();

    if (_isPlayerBusy) {
      return;
    }

    await _drainPlaybackQueue();
  }

  Future<void> toggleFavorite(RadioStation station) async {
    station.isFavorite = !station.isFavorite;
    _recomputeDerivedState();
    await _repository.saveFavorites(_stations);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    themeModeNotifier.value =
        _isDarkMode ? ThemeMode.dark : ThemeMode.light;
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

  void updateSearchQuery(String value) {
    final trimmedValue = value.trim();
    if (_searchQuery == trimmedValue) return;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), () {
      if (_searchQuery == trimmedValue) return;
      _searchQuery = trimmedValue;
      _recomputeDerivedState();
      notifyListeners();
    });
  }

  void selectCountry(String value) {
    if (_selectedCountry == value) return;
    _selectedCountry = value;
    _recomputeDerivedState();
    notifyListeners();
  }

  bool isStationTransitioning(RadioStation station) {
    return _transitioningStationUrl == station.url;
  }

  bool canToggleFavorite(RadioStation station) {
    return !isStationTransitioning(station);
  }

  bool canControlStation(RadioStation station) {
    return !isStationTransitioning(station);
  }

  List<RadioStation> _applyFilter(List<RadioStation> input) {
    final normalizedQuery = _searchQuery.toLowerCase();

    return input.where((station) {
      final matchesCountry =
          _selectedCountry == 'الكل' || station.country == _selectedCountry;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          station.name.toLowerCase().contains(normalizedQuery) ||
          station.country.toLowerCase().contains(normalizedQuery);
      return matchesCountry && matchesQuery;
    }).toList();
  }

  void _recomputeDerivedState() {
    final countries = _stations.map((station) => station.country).toSet().toList();
    countries.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _availableCountries = ['الكل', ...countries];
    _filteredStations = _applyFilter(_stations);
    _favoriteStations = _applyFilter(
      _stations.where((station) => station.isFavorite).toList(),
    );
  }

  Future<void> _drainPlaybackQueue() async {
    if (_isPlayerBusy) {
      return;
    }

    _isPlayerBusy = true;
    notifyListeners();

    try {
      while (_queuedStop || _queuedStation != null) {
        final stationToPlay = _queuedStation;
        final shouldStop = _queuedStop;

        _queuedStation = null;
        _queuedStop = false;

        if (stationToPlay != null) {
          _transitioningStationUrl = stationToPlay.url;
          notifyListeners();

          try {
            await _audioPlayerService.play(
              stationToPlay.url,
              volume: _currentVolume,
            );
            _currentStationUrl = stationToPlay.url;
            _nowPlaying = stationToPlay.name;
            _errorMessage = null;
          } catch (e) {
            _errorMessage = 'فشل تشغيل المحطة: $e';
            _nowPlaying = null;
            _currentStationUrl = null;
          }

          notifyListeners();
          continue;
        }

        if (shouldStop) {
          try {
            await _audioPlayerService.stop();
            _currentStationUrl = null;
            _nowPlaying = null;
            _errorMessage = null;
          } catch (e) {
            _errorMessage = 'فشل إيقاف التشغيل: $e';
          }

          notifyListeners();
        }
      }
    } finally {
      _isPlayerBusy = false;
      _transitioningStationUrl = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _audioPlayerService.dispose();
    _repository.dispose();
    themeModeNotifier.dispose();
    super.dispose();
  }
}
