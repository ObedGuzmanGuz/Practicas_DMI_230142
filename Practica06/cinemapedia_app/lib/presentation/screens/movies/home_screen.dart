import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/providers.dart';
import 'package:cinemapedia_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    drawer: CountryDrawer(),
    body: _HomeView(),
    bottomNavigationBar: CustomBottomNavigation(currentIndex: 0),
  );
}

class _HomeView extends ConsumerStatefulWidget {
  const _HomeView();
  @override
  ConsumerState<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<_HomeView> {
  bool _showSplash = true;
  Timer? _splashTimer;
  bool _resetScrollOnContentBuild = true;

  @override
  void initState() {
    super.initState();
    _loadHomeMovies();
    _splashTimer = Timer(const Duration(milliseconds: 1650), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  void _loadHomeMovies() {
    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
    ref.read(upcomingMoviesProvider.notifier).loadNextPage();
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedMovieRegionProvider, (previous, next) {
      _resetScrollOnContentBuild = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadHomeMovies();
      });
    });
    ref.listen(contentModeProvider, (previous, next) {
      _resetScrollOnContentBuild = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadHomeMovies();
      });
    });

    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final isSeries = ref.watch(contentModeProvider) == ContentMode.series;
    final initialLoading = ref.watch(initialLoadingProvider);

    if (_showSplash) return const _CinemapediaSplash();
    if (initialLoading) return const FullScreenLoader();

    final slideShowMovies = ref.watch(moviesSlideshowProvider);
    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);
    final scrollController = ref.watch(homeScrollControllerProvider);
    if (_resetScrollOnContentBuild) {
      _resetScrollOnContentBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scrollController.hasClients) scrollController.jumpTo(0);
      });
    }

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          floating: true,
          titleSpacing: 0,
          leadingWidth: 58,
          leading: Builder(builder: (context) => IconButton(
            tooltip: strings.settings,
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )),
          title: const CustomAppbar(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 2),
            child: Row(
              children: [
                Expanded(child: Text(
                  strings.homeIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )),
                TextButton.icon(
                  onPressed: () => context.go('/categories'),
                  icon: const Icon(Icons.auto_awesome_mosaic_rounded, size: 17),
                  label: Text(strings.categories),
                ),
              ],
            ),
          ),
        ),
        if (slideShowMovies.isEmpty && nowPlayingMovies.isEmpty && popularMovies.isEmpty && topRatedMovies.isEmpty && upcomingMovies.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_rounded, size: 52),
                const SizedBox(height: 12),
                Text(strings.catalogLoadError, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                FilledButton.icon(onPressed: _loadHomeMovies, icon: const Icon(Icons.refresh_rounded), label: Text(strings.retry)),
              ]),
            )),
          )
        else ...[
        SliverToBoxAdapter(child: MoviesSlideshow(movies: slideShowMovies)),
        SliverToBoxAdapter(child: MovieHorizontalListview(
          movies: nowPlayingMovies,
          title: isSeries ? strings.onAir : strings.nowPlaying,
          loadNextPage: () => ref.read(nowPlayingMoviesProvider.notifier).loadNextPage(),
        )),
        SliverToBoxAdapter(child: MovieHorizontalListview(
          movies: upcomingMovies,
          title: isSeries ? strings.upcomingSeries : strings.upcoming,
          loadNextPage: () => ref.read(upcomingMoviesProvider.notifier).loadNextPage(),
        )),
        SliverToBoxAdapter(child: MovieHorizontalListview(
          movies: popularMovies,
          title: strings.popular,
          loadNextPage: () => ref.read(popularMoviesProvider.notifier).loadNextPage(),
          onSeeAll: () => context.go('/popular'),
        )),
        SliverToBoxAdapter(child: MovieHorizontalListview(
          movies: topRatedMovies,
          title: strings.topRated,
          subTitle: strings.allTime,
          loadNextPage: () => ref.read(topRatedMoviesProvider.notifier).loadNextPage(),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Text(
            isSeries ? 'Cinemapedia Series' : 'Cinemapedia Movies',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
        )),
        ],
      ],
    );
  }
}

class _CinemapediaSplash extends ConsumerWidget {
  const _CinemapediaSplash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings(ref.watch(selectedMovieRegionProvider));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.primary.withValues(alpha: 0.18), colors.surface],
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ZoomIn(duration: const Duration(milliseconds: 850), child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 35, spreadRadius: 3)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/images/cinemapedia_eye.png', width: 104, height: 104),
            ),
          )),
          const SizedBox(height: 20),
          FadeInUp(duration: const Duration(milliseconds: 600), child: Text(
            'Cinemapedia',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7),
          )),
          const SizedBox(height: 7),
          FadeIn(duration: const Duration(milliseconds: 1000), child: Text(
            strings.tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic),
          )),
          const SizedBox(height: 24),
          SizedBox(width: 95, child: LinearProgressIndicator(
            minHeight: 3,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: colors.primary.withValues(alpha: 0.15),
          )),
        ]),
      ),
    );
  }
}
