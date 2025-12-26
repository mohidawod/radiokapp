import 'package:flutter/material.dart';
import 'package:radiokapp/screens/audio_handler.dart';
import 'package:radiokapp/widgets/now_playing_bar.dart';

class FavoritesScreen extends StatelessWidget {
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

  void _handleTap(Map<String, String> station) async {
    final url = station['url'];
    if (url == null) return;

    if (currentStationUrl == url) {
      await audioHandler.stop();
    } else {
      await audioHandler.stop();
      await audioHandler.setUrl(url);
      await audioHandler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحطات المفضلة')),
      body: Column(
        children: [
          Expanded(
            child:
                favoriteStations.isEmpty
                    ? const Center(child: Text('لا يوجد محطات مفضلة بعد'))
                    : ListView.builder(
                      itemCount: favoriteStations.length,
                      itemBuilder: (context, index) {
                        final station = favoriteStations[index];
                        final url = station['url'];
                        final isCurrent = currentStationUrl == url;

                        final dismissibleBackground = Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        );

                        return Dismissible(
                          key: Key(station['url'] ?? station['name'] ?? ''),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: dismissibleBackground,
                          onDismissed: (_) async {
                            if (currentStationUrl == url) {
                              await audioHandler.stop();
                            }
                            onRemove(station);
                          },
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
                                  onPressed: () async {
                                    if (currentStationUrl == url) {
                                      await audioHandler.stop();
                                    }
                                    onRemove(station);
                                  },
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
            audioHandler: audioHandler,
            currentStationName:
                favoriteStations.firstWhere(
                  (s) => s['url'] == currentStationUrl,
                  orElse: () => {'name': ''},
                )['name'] ??
                '',
          ),
        ],
      ),
    );
  }
}
