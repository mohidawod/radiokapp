class RadioStation {
  final String name;
  final String url;
  bool isFavorite;

  RadioStation({
    required this.name,
    required this.url,
    this.isFavorite = false,
  });
}
