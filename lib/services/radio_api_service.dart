import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:radiokapp/models/radio_station.dart';

class RadioApiService {
  static const String _baseUrl =
      'https://de1.api.radio-browser.info/json/stations/bycountry';

  static const List<String> _priorityCountryPaths = [
    'saudi%20arabia',
  ];

  static const List<String> _secondaryCountryPaths = [
    'sudan',
    'egypt',
    'united%20arab%20emirates',
    'kuwait',
    'qatar',
    'bahrain',
    'oman',
    'jordan',
    'lebanon',
    'morocco',
    'algeria',
    'tunisia',
    'libya',
    'iraq',
    'yemen',
    'palestine',
    'syria',
  ];

  final http.Client _client;

  RadioApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<RadioStation>> fetchPriorityStations() async {
    return _fetchStationsForCountries(_priorityCountryPaths);
  }

  Future<List<RadioStation>> fetchAllStations() async {
    return _fetchStationsForCountries([
      ..._priorityCountryPaths,
      ..._secondaryCountryPaths,
    ]);
  }

  Future<List<RadioStation>> _fetchStationsForCountries(
    List<String> countryPaths,
  ) async {
    final results = <List<RadioStation>>[];

    for (final countryPath in countryPaths) {
      results.add(await _fetchStationsSafely(countryPath));
    }

    return results.expand((stations) => stations).toList();
  }

  Future<List<RadioStation>> _fetchStationsSafely(String countryPath) async {
    try {
      return await _fetchStationsByCountryPath(countryPath);
    } catch (_) {
      return const <RadioStation>[];
    }
  }

  Future<List<RadioStation>> _fetchStationsByCountryPath(
    String countryPath,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/$countryPath?hidebroken=true&order=votes&reverse=true',
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('تعذر تحميل المحطات من $countryPath: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;

    return data
        .whereType<Map<String, dynamic>>()
        .map(RadioStation.fromJson)
        .where((station) => station.url.trim().isNotEmpty)
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
