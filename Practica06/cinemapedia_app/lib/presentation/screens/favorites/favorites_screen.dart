import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/movies/movie_poster_card.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/custom_bottom_navigation.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/country_drawer.dart';
import 'package:cinemapedia_app/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia_app/presentation/providers/search/search_movies_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesScreen extends ConsumerWidget {
  static const name = 'favorites-screen';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final isSeries = ref.watch(contentModeProvider) == ContentMode.series;
    final favorites = ref.watch(favoriteMoviesProvider).where((item) => item.isTv == isSeries).toList();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CountryDrawer(),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            leading: Builder(
              builder: (context) => IconButton(
                tooltip: strings.chooseCountry,
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(strings.favorites),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.favorites,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    strings.favoritesSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (favorites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 72,
                        color: colors.primary.withValues(alpha: 0.75),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.noFavorites,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.addFavoritesHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: SearchMovieDelegate(
                              initialMovies: ref.read(searchedMoviesProvider),
                              searchMovies: ref.read(searchedMoviesProvider.notifier).searchMoviesByQuery,
                              searchFieldLabel: strings.searchMovies,
                            ),
                          ).then((movie) {
                            if (movie != null && context.mounted) context.push('/movie/${movie.id}');
                          });
                        },
                        icon: const Icon(Icons.search_rounded),
                        label: Text(strings.searchMovies),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => MoviePosterCard(movie: favorites[index]),
                  childCount: favorites.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.56,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
