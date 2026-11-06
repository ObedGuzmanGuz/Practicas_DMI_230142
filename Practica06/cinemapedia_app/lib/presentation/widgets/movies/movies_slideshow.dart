import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/movie_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoviesSlideshow extends StatelessWidget {
  final List<Movie> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (movies.isEmpty) return const SizedBox(height: 220);

    return SizedBox(
      height: 265,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.88,
        scale: 0.93,
        autoplay: true,
        autoplayDelay: 5200,
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 0),
          builder: DotSwiperPaginationBuilder(
            activeColor: colors.primary,
            color: colors.secondary.withValues(alpha: 0.45),
          ),
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(movie: movies[index]),
      ),
    );
  }
}

class _Slide extends ConsumerWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoriteMoviesProvider.select((items) => items.any((item) => item.id == movie.id)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => context.push('/movie/${movie.id}'),
              child: Image.network(
                movie.backdropPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const Icon(Icons.movie_outlined, size: 42),
                ),
                loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                    ? FadeIn(child: child)
                    : const ColoredBox(color: Colors.black12),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.28, 1],
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Material(
                color: Colors.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 15,
              right: 15,
              bottom: 14,
              child: GestureDetector(
                onTap: () => context.push('/movie/${movie.id}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      MovieStarRating(ratingOutOfTen: movie.voteAverage, iconSize: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
