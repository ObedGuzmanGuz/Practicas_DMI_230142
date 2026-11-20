import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/movies/movie_poster_card.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/custom_bottom_navigation.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/country_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PopularScreen extends ConsumerStatefulWidget {
  static const name = 'popular-screen';
  const PopularScreen({super.key});

  @override
  ConsumerState<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends ConsumerState<PopularScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(popularMoviesProvider).isEmpty) {
        ref.read(popularMoviesProvider.notifier).loadNextPage();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 650) {
      ref.read(popularMoviesProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedMovieRegionProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(popularMoviesProvider.notifier).loadNextPage();
      });
    });
    ref.listen(contentModeProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(popularMoviesProvider.notifier).loadNextPage();
      });
    });
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final isSeries = ref.watch(contentModeProvider) == ContentMode.series;
    final titles = ref.watch(popularMoviesProvider);
    final popularNotifier = ref.read(popularMoviesProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CountryDrawer(),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('${strings.popular} · ${isSeries ? strings.series : strings.movies}'),
            leading: Builder(builder: (context) => IconButton(
              tooltip: strings.settings,
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Text(strings.popularScreenSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
            ),
          ),
          if (titles.isEmpty && !popularNotifier.hasAttempted)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (titles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(strings.catalogLoadError, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => ref.read(popularMoviesProvider.notifier).loadNextPage(),
                    icon: const Icon(Icons.refresh_rounded), label: Text(strings.retry),
                  ),
                ]),
              )),
            )
          else
            SliverToBoxAdapter(
              child: MasonryGridView.count(
                controller: null,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 13,
                padding: const EdgeInsets.fromLTRB(13, 0, 13, 20),
                itemCount: titles.length,
                itemBuilder: (context, index) => MoviePosterCard(
                  movie: titles[index],
                  imageAspectRatio: index % 4 == 0 ? 0.62 : index % 3 == 0 ? 0.72 : 0.67,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
