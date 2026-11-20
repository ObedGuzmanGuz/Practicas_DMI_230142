import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/config/helpers/content_rating_labels.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movie_certification_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoviePosterCard extends ConsumerWidget {
  final Movie movie;
  final double imageAspectRatio;
  const MoviePosterCard({super.key, required this.movie, this.imageAspectRatio = 0.66});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final certification = ref.watch(movieCertificationProvider((id: movie.id, isTv: movie.isTv)));
    final ratingLabel = certification.when(
      data: (value) => ContentRatingLabels.compact(value, region.isoCode),
      loading: () => '···',
      error: (_, __) => ContentRatingLabels.compact(movie.certification, region.isoCode),
    );
    final isFavorite = ref.watch(favoriteMoviesProvider.select((items) =>
      items.any((item) => item.id == movie.id && item.isTv == movie.isTv),
    ));

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/movie/${movie.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: colors.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.movie_creation_outlined, size: 38))),
                loadingBuilder: (context, child, progress) => progress == null ? child
                  : ColoredBox(color: colors.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.transparent, Colors.black54],
                stops: [0, 0.45, 1],
              )))),
              Positioned(top: 6, right: 6, child: Material(
                color: Colors.black.withValues(alpha: 0.62), shape: const CircleBorder(),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: isFavorite ? strings.removeFromFavorites : strings.addToFavorites,
                  onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
                  icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white, size: 19),
                ),
              )),
              Positioned(left: 7, right: 7, bottom: 7, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoPill(icon: Icons.star_rounded, label: movie.voteAverage.toStringAsFixed(1)),
                  _InfoPill(label: ratingLabel),
                ],
              )),
            ]),
          ),
        ),
        const SizedBox(height: 7),
        Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.16)),
        if (movie.releaseDate.year > 1900)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('${movie.releaseDate.year}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
          ),
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _InfoPill({this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(9)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, color: const Color(0xFFFFC857), size: 14), const SizedBox(width: 2)],
      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
    ]),
  );
}
