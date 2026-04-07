class RadioStation {
  final String id;
  final String name;
  final String url;
  final String? faviconUrl;
  bool isFavorite;

  RadioStation({
    required this.id,
    required this.name,
    required this.url,
    this.faviconUrl,
    this.isFavorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    final stationId = (json['stationuuid'] ?? '').toString();
    final stationName = (json['name'] ?? '').toString().trim();
    final resolvedUrl = (json['url_resolved'] ?? json['url'] ?? '').toString();
    final favicon = (json['favicon'] ?? '').toString().trim();

    return RadioStation(
      id: stationId,
      name: stationName.isEmpty ? 'محطة غير معروفة' : stationName,
      url: resolvedUrl,
      faviconUrl: favicon.isEmpty ? null : favicon,
    );
  }
}
