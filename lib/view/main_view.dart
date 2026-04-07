import 'package:flutter/material.dart';
import 'package:radiokapp/models/radio_station.dart';
import 'package:radiokapp/viewmodels/radio_viewmodel.dart';

class MainView extends StatefulWidget {
  static const routeName = '/main';

  final RadioViewModel viewModel;

  const MainView({super.key, required this.viewModel});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    widget.viewModel.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = viewModel.isDarkMode ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تطبيق راديوك'),
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
                                value: viewModel.currentVolume,
                                min: 0,
                                max: 1,
                                divisions: 10,
                                label:
                                    '${(viewModel.currentVolume * 100).round()}%',
                                onChanged: viewModel.changeVolume,
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  viewModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: viewModel.toggleDarkMode,
              ),
              if (viewModel.currentStationUrl != null)
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: viewModel.stopPlaying,
                ),
            ],
          ),
          body:
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      if (viewModel.nowPlaying != null)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'جاري التشغيل: ${viewModel.nowPlaying}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(child: _buildCurrentScreen(viewModel)),
                    ],
                  ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.changeTab,
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

  Widget _buildCurrentScreen(RadioViewModel viewModel) {
    if (viewModel.currentIndex == 1) {
      final favorites = viewModel.favoriteStations;
      return favorites.isEmpty
          ? const Center(child: Text('لا توجد محطات مفضلة بعد'))
          : ListView(children: favorites.map((s) => _buildStationTile(viewModel, s)).toList());
    }

    if (viewModel.currentIndex == 2) {
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
    }

    if (viewModel.stations.isEmpty) {
      return const Center(child: Text('لا توجد محطات متاحة حالياً'));
    }

    return ListView(
      children: viewModel.stations.map((s) => _buildStationTile(viewModel, s)).toList(),
    );
  }

  Widget _buildStationTile(RadioViewModel viewModel, RadioStation station) {
    final isPlaying = viewModel.currentStationUrl == station.url;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _StationAvatar(station: station, isPlaying: isPlaying),
        title: Text(station.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                station.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: station.isFavorite ? Colors.red : null,
              ),
              onPressed: () => viewModel.toggleFavorite(station),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed:
                  isPlaying
                      ? viewModel.stopPlaying
                      : () => viewModel.playStation(station),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationAvatar extends StatelessWidget {
  final RadioStation station;
  final bool isPlaying;

  const _StationAvatar({required this.station, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      Icons.radio,
      color: isPlaying ? Theme.of(context).colorScheme.primary : null,
    );

    final faviconUrl = station.faviconUrl;
    if (faviconUrl == null || faviconUrl.isEmpty) {
      return fallbackIcon;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        faviconUrl,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackIcon,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return fallbackIcon;
        },
      ),
    );
  }
}
