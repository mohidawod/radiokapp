import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:radiokapp/models/radio_station.dart';

class RadioApiService {
  static const List<String> _countryPaths = [
    'saudi%20arabia',
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

  Future<List<RadioStation>> fetchAllStations() async {
    final results = await Future.wait(
      _countryPaths.map(_fetchStationsByCountryPath),
    );

    return results.expand((stations) => stations).toList();
  }

  Future<List<RadioStation>> _fetchStationsByCountryPath(
    String countryPath,
  ) async {
    final uri = Uri.parse(
      'https://de1.api.radio-browser.info/json/stations/bycountry/$countryPath',
    );

    final response = await _client.get(uri);
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
