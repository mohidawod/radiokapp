import 'dart:convert';

import 'package:radiokapp/models/radio_station.dart';
import 'package:radiokapp/services/preferences_service.dart';
import 'package:radiokapp/services/radio_api_service.dart';

class RadioRepository {
  static const Duration _cacheMaxAge = Duration(minutes: 30);

  final RadioApiService _apiService;
  final PreferencesService _preferencesService;

  RadioRepository({
    required RadioApiService apiService,
    required PreferencesService preferencesService,
  }) : _apiService = apiService,
       _preferencesService = preferencesService;

  Future<List<RadioStation>> getCachedStations() async {
    final rawCache = await _preferencesService.getStationsCache();
    if (rawCache == null || rawCache.isEmpty) {
      return <RadioStation>[];
    }

    try {
      final List<dynamic> data = jsonDecode(rawCache) as List<dynamic>;
      final stations =
          data
              .whereType<Map<String, dynamic>>()
              .map(RadioStation.fromCacheJson)
              .toList();
      return _applyFavorites(_sanitizeStations(stations));
    } catch (_) {
      return <RadioStation>[];
    }
  }

  Future<List<RadioStation>> getPriorityStations() async {
    final stations = _sanitizeStations(await _apiService.fetchPriorityStations());
    await _cacheStations(stations);
    return _applyFavorites(stations);
  }

  Future<List<RadioStation>> getStations() async {
    final stations = _sanitizeStations(await _apiService.fetchAllStations());
    await _cacheStations(stations);
    return _applyFavorites(stations);
  }

  Future<List<RadioStation>> _applyFavorites(List<RadioStation> stations) async {
    final favoriteIds = await _preferencesService.getFavorites();

    for (final station in stations) {
      station.isFavorite = favoriteIds.contains(station.id);
    }

    stations.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return stations;
  }

  Future<bool> getDarkMode() {
    return _preferencesService.getDarkMode();
  }

  Future<bool> isCacheFresh() async {
    final updatedAt = await _preferencesService.getStationsCacheUpdatedAt();
    if (updatedAt == null) {
      return false;
    }

    return DateTime.now().difference(updatedAt) <= _cacheMaxAge;
  }

  Future<void> setDarkMode(bool value) {
    return _preferencesService.setDarkMode(value);
  }

  Future<void> saveFavorites(List<RadioStation> stations) {
    final favoriteIds =
        stations.where((station) => station.isFavorite).map((e) => e.id).toList();
    return _preferencesService.setFavorites(favoriteIds);
  }

  Future<void> _cacheStations(List<RadioStation> stations) {
    final encoded = jsonEncode(
      stations.map((station) => station.toCacheJson()).toList(),
    );
    return Future.wait([
      _preferencesService.setStationsCache(encoded),
      _preferencesService.setStationsCacheUpdatedAt(DateTime.now()),
    ]);
  }

  List<RadioStation> _sanitizeStations(List<RadioStation> stations) {
    final uniqueStations = <String, RadioStation>{};

    for (final station in stations) {
      if (!_hasSupportedStream(station.url)) {
        continue;
      }

      final key = '${_normalize(station.name)}|${_normalize(station.url)}';
      final existing = uniqueStations[key];

      if (existing == null) {
        uniqueStations[key] = station;
        continue;
      }

      if ((existing.faviconUrl == null || existing.faviconUrl!.isEmpty) &&
          station.faviconUrl != null &&
          station.faviconUrl!.isNotEmpty) {
        uniqueStations[key] = station;
      }
    }

    return uniqueStations.values.toList();
  }

  bool _hasSupportedStream(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }

    return uri.host.isNotEmpty;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  void dispose() {
    _apiService.dispose();
  }
}
