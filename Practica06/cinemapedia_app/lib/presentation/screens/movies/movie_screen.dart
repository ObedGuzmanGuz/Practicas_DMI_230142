import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/movie_star_rating.dart';

import 'package:cinemapedia_app/presentation/providers/providers.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';


class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();
    
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];
    final selectedRegion = ref.watch(selectedMovieRegionProvider);

    if ( movie == null ) {
      return const Scaffold(body: Center( child: CircularProgressIndicator( strokeWidth: 2)));
    }


    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie, region: selectedRegion),
            childCount: 1
          ))
        ],
      ),
    );
  }
}


class _MovieDetails extends StatelessWidget {
  final Movie movie;
  final MovieRegion region;

  const _MovieDetails({required this.movie, required this.region});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings(region);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contenedor principal de información localizada de la película.
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 9),
              MovieStarRating(ratingOutOfTen: movie.voteAverage, iconSize: 21),
              const SizedBox(height: 15),
              Text(
                strings.genres,
                style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 7,
                runSpacing: 2,
                children: movie.genreIds
                    .map((genre) => Chip(
                          label: Text(genre),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.family_restroom_outlined, color: colors.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.classification,
                          style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          movie.certification.isNotEmpty
                              ? '${movie.certification} · ${region.menuLabel}'
                              : strings.noClassification,
                          style: textStyles.bodyMedium,
                        ),
                        if (movie.certification.isEmpty)
                          Text(
                            region.menuLabel,
                            style: textStyles.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (movie.certification.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        movie.certification,
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: size.width * 0.3,
                    height: 190,
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.movie_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  movie.overview.isNotEmpty
                      ? movie.overview
                      : strings.noOverview,
                  style: textStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            strings.cast,
            style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _ActorsByMovie(movieId: movie.id.toString()),
        const SizedBox(height: 50),
      ],
    );
  }
}

class _ActorsByMovie extends ConsumerWidget {

  final String movieId;

  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {

    final actorsByMovie = ref.watch( actorsByMovieProvider );

    if ( actorsByMovie[movieId] == null ) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }
    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Actor Photo
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      actor.profilePath,
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Nombre
                const SizedBox(height: 5,),

                Text(actor.name, maxLines: 2 ),
                Text(actor.character ?? '', 
                  maxLines: 2,
                  style: const TextStyle( fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis ),
              ),

              ],
            ),
          );


        },
      ),
    );

  }
}





class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;

  const _CustomSliverAppBar({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isFavorite = ref.watch(
      favoriteMoviesProvider.select(
        (items) => items.any((item) => item.id == movie.id),
      ),
    );

    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.62,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.posterPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Colors.black,
                child: Center(child: Icon(Icons.movie_outlined, color: Colors.white, size: 48)),
              ),
              loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                  ? FadeIn(child: child)
                  : const ColoredBox(color: Colors.black),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.42, 1.0],
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
