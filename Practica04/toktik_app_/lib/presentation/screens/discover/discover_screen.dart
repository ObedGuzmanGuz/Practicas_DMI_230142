import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/providers/seasonal_theme_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

enum _FeedSection { discovery, forYou, favorites }

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final PageController _feedController;
  _FeedSection _section = _FeedSection.discovery;

  @override
  void initState() {
    super.initState();
    _feedController = PageController();
  }

  @override
  void dispose() {
    _feedController.dispose();
    super.dispose();
  }

  void _selectSection(_FeedSection section) {
    if (_section == section) return;
    setState(() => _section = section);
    unawaited(_feedController.animateToPage(
      section.index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    ));
  }

  void _onSeasonSelected(SeasonMode mode) {
    unawaited(context.read<SeasonalThemeProvider>().setMode(mode));
  }

  Widget _feed({
    required String keyName,
    required List<VideoPost> videos,
    required bool active,
  }) {
    final key = keyName;
    if (videos.isEmpty) {
      final emptyDetails = switch (keyName) {
        'favorites' => (
            'Aún no tienes favoritos',
            'Dale Me gusta a un video y aparecerá aquí.',
            Icons.favorite_border,
          ),
        'for-you' => (
            'Tu feed Para ti está vacío',
            'Esta sección muestra únicamente videos encontrados con YouTube Data API. Comprueba la conexión y la clave de API.',
            Icons.play_circle_outline,
          ),
        _ => (
            'No hay videos para mostrar',
            'Comprueba tu conexión para cargar los videos de las otras fuentes.',
            Icons.explore_outlined,
          ),
      };
      return _EmptyFavorites(
        key: ValueKey('empty-$keyName'),
        title: emptyDetails.$1,
        message: emptyDetails.$2,
        icon: emptyDetails.$3,
      );
    }
    return VideoScrollableView(
      key: ValueKey(key),
      videos: videos,
      feedActive: active,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    final themeProvider = context.watch<SeasonalThemeProvider>();

    if (provider.initialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final palette = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _feedController,
            onPageChanged: (index) => setState(() {
              _section = _FeedSection.values[index];
            }),
            children: [
              _feed(
                keyName: 'discovery',
                videos: provider.videos,
                active: _section == _FeedSection.discovery,
              ),
              _feed(
                keyName: 'for-you',
                videos: provider.forYouVideos,
                active: _section == _FeedSection.forYou,
              ),
              _feed(
                keyName: 'favorites',
                videos: provider.favoritesVideos,
                active: _section == _FeedSection.favorites,
              ),
            ],
          ),
          _TopNavigation(
            section: _section,
            favoritesCount: provider.favoritesCount,
            season: themeProvider.season,
            mode: themeProvider.mode,
            musicEnabled: themeProvider.musicEnabled,
            onSelected: _selectSection,
            onSeasonSelected: _onSeasonSelected,
            onMusicPressed: () => unawaited(themeProvider.toggleMusic()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary, palette.tertiary],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({
    required this.section,
    required this.favoritesCount,
    required this.season,
    required this.mode,
    required this.musicEnabled,
    required this.onSelected,
    required this.onSeasonSelected,
    required this.onMusicPressed,
  });

  final _FeedSection section;
  final int favoritesCount;
  final AppSeason season;
  final SeasonMode mode;
  final bool musicEnabled;
  final ValueChanged<_FeedSection> onSelected;
  final ValueChanged<SeasonMode> onSeasonSelected;
  final VoidCallback onMusicPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                bg.withValues(alpha: .98),
                bg.withValues(alpha: .84),
                bg.withValues(alpha: .04),
              ],
              stops: const [0, .72, 1],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _SeasonalLogo(season: season),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TokTik Azul',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_seasonCode(season)}  ${season.label.toUpperCase()}  ·  TEMA ACTIVO',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 9,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showSeasonPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(season.icon, size: 17, color: colors.primary),
                            const SizedBox(width: 5),
                            const Text(
                              'Tema',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.expand_more, size: 16, color: colors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    tooltip: musicEnabled ? 'Silenciar música de temporada' : 'Reproducir música de temporada',
                    onPressed: onMusicPressed,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      color: musicEnabled ? colors.primary : colors.onSurface.withValues(alpha: .65),
                      size: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Discover',
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore,
                      active: section == _FeedSection.discovery,
                      onTap: () => onSelected(_FeedSection.discovery),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabButton(
                      label: 'For You',
                      icon: Icons.auto_awesome_outlined,
                      activeIcon: Icons.auto_awesome,
                      active: section == _FeedSection.forYou,
                      onTap: () => onSelected(_FeedSection.forYou),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TabButton(
                      label: 'Favorites',
                      icon: Icons.favorite_border,
                      activeIcon: Icons.favorite,
                      active: section == _FeedSection.favorites,
                      count: favoritesCount,
                      onTap: () => onSelected(_FeedSection.favorites),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSeasonPicker(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Personaliza tu TokTik',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: colors.onSurface),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Cada temporada cambia los colores, el distintivo del logo y su pequeña melodía.',
              style: TextStyle(fontSize: 13, height: 1.35, color: colors.onSurface.withValues(alpha: .68)),
            ),
            const SizedBox(height: 16),
            _SeasonOption(
              title: 'Automático por fecha',
              subtitle: 'Usa la temporada del calendario',
              symbol: Icons.calendar_month_rounded,
              palette: SeasonalPalette.forSeason(season),
              selected: mode == SeasonMode.automatic,
              onTap: () {
                Navigator.pop(sheetContext);
                onSeasonSelected(SeasonMode.automatic);
              },
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SeasonOption(
                    title: 'Normal',
                    subtitle: 'Azul y violeta',
                    symbol: Icons.auto_awesome,
                    palette: SeasonalPalette.forSeason(AppSeason.normal),
                    selected: mode == SeasonMode.normal,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onSeasonSelected(SeasonMode.normal);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SeasonOption(
                    title: 'Halloween',
                    subtitle: 'Naranja y morado',
                    symbol: Icons.nightlight_round,
                    palette: SeasonalPalette.forSeason(AppSeason.halloween),
                    selected: mode == SeasonMode.halloween,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onSeasonSelected(SeasonMode.halloween);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SeasonOption(
                    title: 'Navidad',
                    subtitle: 'Verde y rojo',
                    symbol: Icons.ac_unit,
                    palette: SeasonalPalette.forSeason(AppSeason.christmas),
                    selected: mode == SeasonMode.christmas,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onSeasonSelected(SeasonMode.christmas);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SeasonOption(
                    title: "Valentine's Day",
                    subtitle: 'Rosa y frambuesa',
                    symbol: Icons.favorite_rounded,
                    palette: SeasonalPalette.forSeason(AppSeason.valentinesDay),
                    selected: mode == SeasonMode.valentinesDay,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onSeasonSelected(SeasonMode.valentinesDay);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonalLogo extends StatelessWidget {
  const _SeasonalLogo({required this.season});
  final AppSeason season;

  @override
  Widget build(BuildContext context) {
    final palette = SeasonalPalette.forSeason(season);
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [palette.primary, palette.secondary]),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(color: palette.primary.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            child: Image.asset('assets/brand/toktik_icon.png', fit: BoxFit.contain),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surface,
                shape: BoxShape.circle,
                border: Border.all(color: palette.primary, width: 1.4),
              ),
              child: Icon(_seasonIcon(season), size: 12, color: palette.primary),
            ),
          ),
        ],
      ),
    );
  }
}

String _seasonCode(AppSeason season) => switch (season) {
      AppSeason.normal => 'OK',
      AppSeason.halloween => 'H',
      AppSeason.christmas => 'N',
      AppSeason.valentinesDay => 'V',
    };

IconData _seasonIcon(AppSeason season) => switch (season) {
      AppSeason.normal => Icons.auto_awesome,
      AppSeason.halloween => Icons.nightlight_round,
      AppSeason.christmas => Icons.ac_unit,
      AppSeason.valentinesDay => Icons.favorite_rounded,
    };

class _SeasonOption extends StatelessWidget {
  const _SeasonOption({
    required this.title,
    required this.subtitle,
    required this.symbol,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData symbol;
  final SeasonalPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: palette.surface.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? palette.primary : colors.onSurface.withValues(alpha: .08),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [palette.primary.withValues(alpha: .25), palette.secondary.withValues(alpha: .20)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(symbol, size: 21, color: palette.primary),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, height: 1.1, fontWeight: FontWeight.w900, color: palette.text)),
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, height: 1.2, color: palette.secondaryText)),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 5),
                Icon(Icons.check_circle, color: palette.primary, size: 17),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = active ? colors.onSurface : colors.onSurface.withValues(alpha: .62);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(
          color: active ? colors.primary.withValues(alpha: .13) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? colors.primary.withValues(alpha: .34) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? activeIcon : icon,
                    size: 13, color: active ? colors.primary : foreground),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 3),
                  Container(
                    constraints: const BoxConstraints(minWidth: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              width: active ? 28 : 0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary, colors.tertiary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary, colors.tertiary],
              ),
              boxShadow: [
                BoxShadow(color: colors.primary.withValues(alpha: .2), blurRadius: 28),
              ],
            ),
            child: Icon(icon, color: colors.onPrimary, size: 44),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurface.withValues(alpha: .65), fontSize: 14, height: 1.35),
          ),
        ],
      ),
    );
  }
}
