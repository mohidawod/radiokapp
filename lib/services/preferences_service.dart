import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _darkModeKey = 'darkMode';
  static const _favoritesKey = 'favorites';
  static const _stationsCacheKey = 'stations_cache';
  static const _stationsCacheUpdatedAtKey = 'stations_cache_updated_at';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, value);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await _prefs;
    return prefs.getStringList(_favoritesKey) ?? <String>[];
  }

  Future<void> setFavorites(List<String> stationIds) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoritesKey, stationIds);
  }

  Future<String?> getStationsCache() async {
    final prefs = await _prefs;
    return prefs.getString(_stationsCacheKey);
  }

  Future<void> setStationsCache(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_stationsCacheKey, value);
  }

  Future<DateTime?> getStationsCacheUpdatedAt() async {
    final prefs = await _prefs;
    final rawValue = prefs.getString(_stationsCacheUpdatedAtKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  Future<void> setStationsCacheUpdatedAt(DateTime value) async {
    final prefs = await _prefs;
    await prefs.setString(_stationsCacheUpdatedAtKey, value.toIso8601String());
  }
}
