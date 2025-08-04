import 'package:flutter/material.dart';
import 'package:radiokapp/screens/audio_handler.dart';
import 'package:radiokapp/widgets/now_playing_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, String>> favoriteStations;
  final Function(Map<String, String>) onRemove;
  final AudioHandler audioHandler;
  final String? currentStationUrl;

  const FavoritesScreen({
    super.key,
    required this.favoriteStations,
    required this.onRemove,
    required this.audioHandler,
    required this.currentStationUrl,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Map<String, String>> _favoriteStations;

  @override
  void initState() {
    super.initState();
    _favoriteStations = List<Map<String, String>>.from(widget.favoriteStations);
  }

  void _handleTap(Map<String, String> station) async {
    final url = station['url'];
    if (url == null) return;

    if (widget.currentStationUrl == url) {
      await widget.audioHandler.stop();
    } else {
      await widget.audioHandler.stop();
      await widget.audioHandler.setUrl(url);
      await widget.audioHandler.play();
    }
  }

  Future<void> _removeStation(Map<String, String> station) async {
    setState(() {
      _favoriteStations
          .removeWhere((s) => s['url'] == station['url']);
    });
    widget.onRemove(station);
    final prefs = await SharedPreferences.getInstance();
    final favoriteNames = _favoriteStations
        .map((s) => s['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    await prefs.setStringList('favorites', favoriteNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحطات المفضلة')),
      body: Column(
        children: [
          Expanded(
            child: _favoriteStations.isEmpty
                ? const Center(child: Text('لا يوجد محطات مفضلة بعد'))
                : ListView.builder(
                    itemCount: _favoriteStations.length,
                    itemBuilder: (context, index) {
                      final station = _favoriteStations[index];
                      final url = station['url'];
                      final isCurrent = widget.currentStationUrl == url;

                      return Dismissible(
                        key: ValueKey(station['url']),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child:
                              const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => _removeStation(station),
                        child: ListTile(
                          leading: Icon(
                            Icons.radio,
                            color: isCurrent ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            station['name'] ?? 'محطة غير معروفة',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isCurrent ? Icons.stop : Icons.play_arrow,
                                ),
                                onPressed: () => _handleTap(station),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeStation(station),
                              ),
                            ],
                          ),
                          onTap: () => _handleTap(station),
                        ),
                      );
                    },
                  ),
          ),
          NowPlayingBar(
            audioHandler: widget.audioHandler,
            currentStationName: _favoriteStations
                    .firstWhere(
                      (s) => s['url'] == widget.currentStationUrl,
                      orElse: () => {'name': ''},
                    )['name'] ??
                '',
          ),
        ],
      ),
    );
  }
}
