import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:radiokapp/screens/audio_handler.dart';
import 'package:radiokapp/widgets/now_playing_bar.dart';
import 'package:radiokapp/screens/now_playing_screen.dart';

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

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final AudioHandler audioHandler;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.audioHandler,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RadioStation> _stations = [];
  late SharedPreferences _prefs;
  bool _isReady = false;
  int _currentIndex = 0;
  String? _currentStationUrl;

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoadStations();
  }

  Future<void> _initPrefsAndLoadStations() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStations();
    setState(() {
      _isReady = true;
    });
  }

  void _loadStations() {
    final stations = [
      RadioStation(
        name: 'Monte Carlo Doualiya',
        url: 'https://montecarlodoualiya128k.ice.infomaniak.ch/mc-doualiya.mp3',
      ),
      // أضف باقي المحطات هنا...
    ];

    final savedFavorites = _prefs.getStringList('favorites') ?? [];
    for (var station in stations) {
      if (savedFavorites.contains(station.name)) {
        station.isFavorite = true;
      }
    }
    _stations = stations;
  }

  Future<void> _saveFavorites() async {
    final favoriteNames =
        _stations.where((s) => s.isFavorite).map((s) => s.name).toList();
    await _prefs.setStringList('favorites', favoriteNames);
  }

  void _toggleFavorite(RadioStation station) {
    setState(() {
      station.isFavorite = !station.isFavorite;
    });
    _saveFavorites();
  }

  Future<void> _selectStation(RadioStation station) async {
    if (_currentStationUrl == station.url) {
      await widget.audioHandler.stop();
      setState(() {
        _currentStationUrl = null;
      });
    } else {
      await widget.audioHandler.stop();
      await widget.audioHandler.setUrl(station.url);
      await widget.audioHandler.play();
      setState(() {
        _currentStationUrl = station.url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تطبيق الراديو'),
          actions: [
            IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: widget.onToggleDarkMode,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildCurrentScreen()),
            NowPlayingBar(
              audioHandler: widget.audioHandler,
              currentStationName:
                  _stations
                      .firstWhere(
                        (s) => s.url == _currentStationUrl,
                        orElse: () => RadioStation(name: '', url: ''),
                      )
                      .name,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'عن التطبيق',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildFavoritesScreen();
      case 2:
        return _buildAboutScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
        children: _stations.map((station) {
          final isCurrent = _currentStationUrl == station.url;
          return Hero(
            tag: station.name,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.identity()
                ..scale(isCurrent ? 1.05 : 1.0),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await _selectStation(station);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NowPlayingScreen(
                            audioHandler: widget.audioHandler,
                            stationName: station.name,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radio,
                          size: 40,
                          color: isCurrent ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          station.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            station.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                station.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(station),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoritesScreen() {
    final favorites = _stations.where((s) => s.isFavorite).toList();
    if (favorites.isEmpty) {
      return const Center(child: Text('لا توجد محطات مفضلة'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final station = favorites[index];
        final isCurrent = _currentStationUrl == station.url;
        return ListTile(
          leading: Icon(
            Icons.radio,
            color: isCurrent ? Colors.blue : Colors.grey,
          ),
          title: Text(station.name),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _toggleFavorite(station),
          ),
          onTap: () => _selectStation(station),
        );
      },
    );
  }

  Widget _buildAboutScreen() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'تطبيق راديو بسيط.\nتم التطوير باستخدام Flutter.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
