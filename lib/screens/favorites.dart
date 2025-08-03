import 'package:flutter/material.dart';
import 'package:radiokapp/screens/audio_handler.dart';
import 'package:radiokapp/widgets/now_playing_bar.dart';

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
  bool _isBusy = false;

  void _handleTap(Map<String, String> station) async {
    if (_isBusy) return;
    final url = station['url'];
    if (url == null) return;
    _isBusy = true;
    try {
      if (widget.currentStationUrl == url) {
        await widget.audioHandler.stop();
      } else {
        await widget.audioHandler.stop();
        await widget.audioHandler.setUrl(url);
        await widget.audioHandler.play();
      }
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحطات المفضلة')),
      body: Column(
        children: [
          Expanded(
            child: widget.favoriteStations.isEmpty
                ? const Center(child: Text('لا يوجد محطات مفضلة بعد'))
                : ListView.builder(
                    itemCount: widget.favoriteStations.length,
                    itemBuilder: (context, index) {
                      final station = widget.favoriteStations[index];
                      final url = station['url'];
                      final isCurrent = widget.currentStationUrl == url;

                      return ListTile(
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
                              onPressed: () => widget.onRemove(station),
                            ),
                          ],
                        ),
                        onTap: () => _handleTap(station),
                      );
                    },
                  ),
          ),
          NowPlayingBar(
            audioHandler: widget.audioHandler,
            currentStationName: widget.favoriteStations.firstWhere(
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
