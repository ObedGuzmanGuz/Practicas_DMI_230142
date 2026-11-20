import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia_app/presentation/providers/providers.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/cinemapedia_eye.png',
                width: 38,
                height: 38,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cinemapedia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    strings.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: strings.searchMovies,
              onPressed: () {
                final searchedMovies = ref.read(searchedMoviesProvider);
                final searchQuery = ref.read(searchQueryProvider);
                showSearch(
                  context: context,
                  query: searchQuery,
                  delegate: SearchMovieDelegate(
                    initialMovies: searchedMovies,
                    searchMovies: ref.read(searchedMoviesProvider.notifier).searchMoviesByQuery,
                    searchFieldLabel: strings.searchMovies,
                  ),
                ).then((movie) {
                  if (movie == null || !context.mounted) return;
                  context.push('/movie/${movie.id}');
                });
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
