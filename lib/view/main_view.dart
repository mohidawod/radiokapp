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
  static const int _pageSize = 40;

  final ScrollController _homeScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _visibleHomeStations = _pageSize;

  @override
  void initState() {
    super.initState();
    _homeScrollController.addListener(_handleHomeScroll);
  }

  @override
  void dispose() {
    _homeScrollController
      ..removeListener(_handleHomeScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleHomeScroll() {
    if (!_homeScrollController.hasClients) {
      return;
    }

    final position = _homeScrollController.position;
    if (position.pixels < position.maxScrollExtent - 300) {
      return;
    }

    final totalStations = widget.viewModel.filteredStations.length;
    if (_visibleHomeStations >= totalStations) {
      return;
    }

    setState(() {
      _visibleHomeStations = (_visibleHomeStations + _pageSize).clamp(
        _pageSize,
        totalStations,
      );
    });
  }

  int _effectiveVisibleCount(int totalStations) {
    if (totalStations <= _pageSize) {
      return totalStations;
    }

    return _visibleHomeStations.clamp(_pageSize, totalStations);
  }

  @override
  Widget build(BuildContext context) {
    final totalStations = widget.viewModel.filteredStations.length;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_visibleHomeStations > totalStations && totalStations > 0) {
      _visibleHomeStations = totalStations;
    }

    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        final filteredStations = viewModel.filteredStations;
        final favoriteStations = viewModel.favoriteStations;
        final availableCountries = viewModel.availableCountries;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 76,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('راديوك'),
                  Text(
                    viewModel.currentIndex == 0
                        ? 'محطات منتقاة بواجهة أخف'
                        : viewModel.currentIndex == 1
                        ? 'محطاتك المفضلة'
                        : 'عن التطبيق',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                _TopAction(
                  icon: Icons.equalizer_rounded,
                  onTap: () => _showVolumeSheet(context, viewModel),
                ),
                _TopAction(
                  icon:
                      viewModel.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                  onTap: viewModel.toggleDarkMode,
                ),
                if (viewModel.currentStationUrl != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: _TopAction(
                      icon: Icons.stop_rounded,
                      onTap:
                          viewModel.isPlayerBusy ? null : viewModel.stopPlaying,
                    ),
                  ),
              ],
            ),
            body:
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                            child: _StatusPanel(
                              nowPlaying: viewModel.nowPlaying,
                              errorMessage: viewModel.errorMessage,
                              isRefreshing: viewModel.isRefreshing,
                            ),
                          ),
                          _buildFilters(viewModel, availableCountries),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? colorScheme.surface
                                          : colorScheme.surface.withValues(
                                            alpha: 0.74,
                                          ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                ),
                                child: _buildCurrentScreen(
                                  viewModel,
                                  filteredStations,
                                  favoriteStations,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BottomNavigationBar(
                  currentIndex: viewModel.currentIndex,
                  onTap: viewModel.changeTab,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded),
                      label: 'الرئيسية',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_outline_rounded),
                      activeIcon: Icon(Icons.favorite_rounded),
                      label: 'المفضلة',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.info_outline_rounded),
                      label: 'عن التطبيق',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
    RadioViewModel viewModel,
    List<RadioStation> filteredStations,
    List<RadioStation> favoriteStations,
  ) {
    if (viewModel.currentIndex == 1) {
      return favoriteStations.isEmpty
          ? const _EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'لا توجد محطات مطابقة في المفضلة',
            subtitle: 'أضف بعض المحطات إلى المفضلة لتصل إليها بسرعة لاحقًا.',
          )
          : ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            itemCount: favoriteStations.length,
            itemBuilder:
                (context, index) =>
                    _buildStationTile(viewModel, favoriteStations[index]),
          );
    }

    if (viewModel.currentIndex == 2) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, 28, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoCard(
              icon: Icons.layers_outlined,
              title: 'تصميم مسطح وعصري',
              subtitle: 'واجهة أخف بصريًا مع ألوان أوضح ومساحات أنيقة.',
            ),
            SizedBox(height: 12),
            _InfoCard(
              icon: Icons.speed_rounded,
              title: 'تركيز على السلاسة',
              subtitle: 'تحميل تدريجي وكاش محلي وانتقال أفضل بين المحطات.',
            ),
            SizedBox(height: 12),
            _InfoCard(
              icon: Icons.tune_rounded,
              title: 'تحكم أسرع',
              subtitle: 'بحث، تصفية، مفضلة، وتحكم بالصوت في مسار واحد بسيط.',
            ),
          ],
        ),
      );
    }

    if (filteredStations.isEmpty) {
      return const _EmptyState(
        icon: Icons.radio_outlined,
        title: 'لا توجد محطات متاحة حالياً',
        subtitle: 'جرّب تغيير البحث أو اختيار دولة أخرى لعرض نتائج مختلفة.',
      );
    }

    final visibleCount = _effectiveVisibleCount(filteredStations.length);

    return ListView.builder(
      controller: _homeScrollController,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      itemCount: visibleCount,
      itemExtent: 96,
      cacheExtent: 500,
      itemBuilder:
          (context, index) =>
              _buildStationTile(viewModel, filteredStations[index]),
    );
  }

  Widget _buildFilters(
    RadioViewModel viewModel,
    List<String> availableCountries,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              viewModel.updateSearchQuery(value);
              _resetVisibleStations();
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث عن محطة أو دولة',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon:
                  viewModel.searchQuery.isEmpty
                      ? null
                      : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.updateSearchQuery('');
                          _resetVisibleStations();
                        },
                      ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableCountries.length,
              separatorBuilder:
                  (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final country = availableCountries[index];
                final isSelected = country == viewModel.selectedCountry;
                return ChoiceChip(
                  label: Text(country),
                  selected: isSelected,
                  avatar:
                      isSelected
                          ? const Icon(Icons.done_rounded, size: 16)
                          : null,
                  onSelected: (_) {
                    viewModel.selectCountry(country);
                    _resetVisibleStations();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _resetVisibleStations() {
    if (_visibleHomeStations == _pageSize) {
      return;
    }

    setState(() {
      _visibleHomeStations = _pageSize;
    });
  }

  Widget _buildStationTile(RadioViewModel viewModel, RadioStation station) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlaying = viewModel.currentStationUrl == station.url;
    final isTransitioning = viewModel.isStationTransitioning(station);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:
            isPlaying
                ? colorScheme.primary.withValues(alpha: 0.10)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _StationAvatar(
            station: station,
            isPlaying: isPlaying,
            enableNetworkImage: station.isFavorite || isPlaying,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          station.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    if (isPlaying) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.multitrack_audio_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'إضافة إلى المفضلة',
            icon: Icon(
              station.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: station.isFavorite ? const Color(0xFFE45858) : null,
            ),
            onPressed:
                !viewModel.canToggleFavorite(station)
                    ? null
                    : () => viewModel.toggleFavorite(station),
          ),
          SizedBox(
            width: 46,
            height: 46,
            child:
                isTransitioning
                    ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                    : FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed:
                          !viewModel.canControlStation(station)
                              ? null
                              : isPlaying
                              ? viewModel.stopPlaying
                              : () => viewModel.playStation(station),
                      child: Icon(
                        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  void _showVolumeSheet(BuildContext context, RadioViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحكم في الصوت',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'اضبط مستوى الصوت بسرعة أثناء الاستماع.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.volume_down_rounded),
                    Expanded(
                      child: Slider(
                        value: viewModel.currentVolume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(viewModel.currentVolume * 100).round()}%',
                        onChanged: viewModel.changeVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded),
                  ],
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
  final bool enableNetworkImage;

  const _StationAvatar({
    required this.station,
    required this.isPlaying,
    required this.enableNetworkImage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fallbackIcon = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color:
            isPlaying
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.radio_rounded,
        color: isPlaying ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );

    final faviconUrl = station.faviconUrl;
    if (!enableNetworkImage || faviconUrl == null || faviconUrl.isEmpty) {
      return fallbackIcon;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        faviconUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        cacheWidth: 96,
        cacheHeight: 96,
        filterQuality: FilterQuality.low,
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

class _TopAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final String? nowPlaying;
  final String? errorMessage;
  final bool isRefreshing;

  const _StatusPanel({
    required this.nowPlaying,
    required this.errorMessage,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (nowPlaying == null && errorMessage == null && !isRefreshing) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nowPlaying != null)
            Row(
              children: [
                Icon(Icons.graphic_eq_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'جاري التشغيل: $nowPlaying',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          if (errorMessage != null) ...[
            if (nowPlaying != null) const SizedBox(height: 10),
            Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (isRefreshing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
