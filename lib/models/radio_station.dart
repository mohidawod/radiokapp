class RadioStation {
  final String id;
  final String name;
  final String url;
  final String country;
  final String? faviconUrl;
  bool isFavorite;

  RadioStation({
    required this.id,
    required this.name,
    required this.url,
    required this.country,
    this.faviconUrl,
    this.isFavorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    final stationId = (json['stationuuid'] ?? '').toString();
    final stationName = (json['name'] ?? '').toString().trim();
    final resolvedUrl = (json['url_resolved'] ?? json['url'] ?? '').toString();
    final countryName = (json['country'] ?? '').toString().trim();
    final favicon = (json['favicon'] ?? '').toString().trim();

    return RadioStation(
      id: stationId,
      name: stationName.isEmpty ? 'محطة غير معروفة' : stationName,
      url: resolvedUrl,
      country: countryName.isEmpty ? 'غير محدد' : countryName,
      faviconUrl: favicon.isEmpty ? null : favicon,
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'country': country,
      'faviconUrl': faviconUrl,
    };
  }

  factory RadioStation.fromCacheJson(Map<String, dynamic> json) {
    return RadioStation(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'محطة غير معروفة').toString(),
      url: (json['url'] ?? '').toString(),
      country: (json['country'] ?? 'غير محدد').toString(),
      faviconUrl:
          json['faviconUrl']?.toString().trim().isEmpty ?? true
              ? null
              : json['faviconUrl'].toString(),
    );
  }
}
