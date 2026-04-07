import 'package:radiokapp/models/radio_station.dart';
import 'package:radiokapp/services/preferences_service.dart';
import 'package:radiokapp/services/radio_api_service.dart';

class RadioRepository {
  final RadioApiService _apiService;
  final PreferencesService _preferencesService;

  RadioRepository({
    required RadioApiService apiService,
    required PreferencesService preferencesService,
  }) : _apiService = apiService,
       _preferencesService = preferencesService;

  Future<List<RadioStation>> getStations() async {
    final stations = _sanitizeStations(await _apiService.fetchAllStations());
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

  Future<void> setDarkMode(bool value) {
    return _preferencesService.setDarkMode(value);
  }

  Future<void> saveFavorites(List<RadioStation> stations) {
    final favoriteIds =
        stations.where((station) => station.isFavorite).map((e) => e.id).toList();
    return _preferencesService.setFavorites(favoriteIds);
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
}
