import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:radiokapp/models/radio_station.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyAppEntry());
}

class MyAppEntry extends StatelessWidget {
  const MyAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'مرحباً بكم في راديونا',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('ابدأ الاستماع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AudioPlayer _player;
  late SharedPreferences _prefs;

  List<RadioStation> _stations = [];
  bool _isDarkMode = false;
  int _currentIndex = 0;
  double _currentVolume = 1.0;
  String? _currentStationUrl;
  String? _errorMessage;
  String? _nowPlaying;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initApp();
  }

  Future<void> _initApp() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('darkMode') ?? false;
    _loadStations();
    setState(() {});
  }

  void _loadStations() {
    _stations = [
      RadioStation(
        name: 'Monte Carlo Doualiya',
        url: 'https://montecarlodoualiya128k.ice.infomaniak.ch/mc-doualiya.mp3',
      ),
      RadioStation(
        name: 'BBC English',
        url: 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      ),
      RadioStation(
        name: 'Radio Asharq',
        url:
            'https://l3.itworkscdn.net/asharqradioalive/asharqradioa/icecast.audio',
      ),
      RadioStation(
        name: ' Mishary Alafasy ',
        url: 'https://qurango.net/radio/mishary_alafasi',
      ),
      RadioStation(
        name: 'Radio Dabangasudan',
        url: 'https://stream.dabangasudan.org',
      ),
      RadioStation(
        name: 'BBC Arabic',
        url: 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      ),
      RadioStation(
        name: 'Al araby',
        url:
            'https://l3.itworkscdn.net/alarabyradiolive/alarabyradio_audio/icecast.audio',
      ),
      RadioStation(
        name: 'Saudi TV English',
        url: 'http://104.7.66.64:8010/;?icy=http',
      ),
      RadioStation(
        name: 'AlifAlif FM',
        url: 'https://alifalifjobs.com/radio/8000/AlifAlifLive.mp3',
      ),
      RadioStation(
        name: 'MIX FM KSA',
        url: 'https://s1.voscast.com:11377/live.mp3',
      ),
      RadioStation(
        name: '	sky news UK',
        url: 'https://tunein.cdnstream1.com/3688_96.mp3?',
      ),
    ];

    final favorites = _prefs.getStringList('favorites') ?? [];
    for (var station in _stations) {
      station.isFavorite = favorites.contains(station.name);
    }
  }

  Future<void> _playStation(RadioStation station) async {
    try {
      await _player.stop();
      await _player.setUrl(station.url);
      await _player.play();
      setState(() {
        _currentStationUrl = station.url;
        _nowPlaying = station.name;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تشغيل المحطة: $e';
        _nowPlaying = null;
        _currentStationUrl = null;
      });
    }
  }

  Future<void> _stopPlaying() async {
    await _player.stop();
    setState(() {
      _currentStationUrl = null;
      _nowPlaying = null;
    });
  }

  void _toggleFavorite(RadioStation station) {
    station.isFavorite = !station.isFavorite;
    _prefs.setStringList(
      'favorites',
      _stations.where((s) => s.isFavorite).map((s) => s.name).toList(),
    );
    setState(() {});
  }

  void _toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('darkMode', _isDarkMode);
    setState(() {});
  }

  void _changeVolume(double volume) {
    _currentVolume = volume;
    _player.setVolume(volume);
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تطبيق راديو يلا'),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (_) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تحكم في الصوت'),
                              Slider(
                                value: _currentVolume,
                                min: 0,
                                max: 1,
                                divisions: 10,
                                label: '${(_currentVolume * 100).round()}%',
                                onChanged: _changeVolume,
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleDarkMode,
              ),
              if (_currentStationUrl != null)
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _stopPlaying,
                ),
            ],
          ),
          body: Column(
            children: [
              if (_nowPlaying != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'جاري التشغيل: $_nowPlaying',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(child: _buildCurrentScreen()),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
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
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_currentIndex == 1) {
      final favs = _stations.where((s) => s.isFavorite).toList();
      return favs.isEmpty
          ? const Center(child: Text('لا توجد محطات مفضلة بعد'))
          : ListView(children: favs.map(_buildStationTile).toList());
    } else if (_currentIndex == 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'تطبيق راديو بسيط مبني بـ Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } else {
      return ListView(children: _stations.map(_buildStationTile).toList());
    }
  }

  Widget _buildStationTile(RadioStation station) {
    final isPlaying = _currentStationUrl == station.url;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.radio),
        title: Text(station.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                station.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: station.isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(station),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: isPlaying ? _stopPlaying : () => _playStation(station),
            ),
          ],
        ),
      ),
    );
  }
}

}
