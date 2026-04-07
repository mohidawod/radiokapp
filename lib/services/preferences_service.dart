import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool('darkMode', value);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await _prefs;
    return prefs.getStringList('favorites') ?? <String>[];
  }

  Future<void> setFavorites(List<String> stationIds) async {
    final prefs = await _prefs;
    await prefs.setStringList('favorites', stationIds);
  }
}
