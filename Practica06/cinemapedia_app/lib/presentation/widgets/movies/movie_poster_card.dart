import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/movie_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoviePosterCard extends ConsumerWidget {
  final Movie movie;

  const MoviePosterCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isFavorite = ref.watch(
      favoriteMoviesProvider.select(
        (movies) => movies.any((item) => item.id == movie.id),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/movie/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.posterPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.movie_outlined, size: 38),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : ColoredBox(
                            color: colors.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                        onPressed: () => ref
                            .read(favoriteMoviesProvider.notifier)
                            .toggle(movie),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFFC857), size: 15),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
          ),
        ],
      ),
    );
  }
}
