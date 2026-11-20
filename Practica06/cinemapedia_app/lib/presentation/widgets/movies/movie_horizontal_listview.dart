import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/config/helpers/content_rating_labels.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movie_certification_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MovieHorizontalListview extends StatefulWidget {
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;
  final VoidCallback? onSeeAll;

  const MovieHorizontalListview({super.key, required this.movies, this.title, this.subTitle, this.loadNextPage, this.onSeeAll});
  @override
  State<MovieHorizontalListview> createState() => _MovieHorizontalListviewState();
}

class _MovieHorizontalListviewState extends State<MovieHorizontalListview> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.loadNextPage == null || !scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 220) widget.loadNextPage!();
  }

  @override
  void dispose() { scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 315,
      child: Column(children: [
        if (widget.title != null || widget.subTitle != null)
          _Title(title: widget.title, subTitle: widget.subTitle, onSeeAll: widget.onSeeAll),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: widget.movies.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            itemBuilder: (context, index) => FadeInRight(child: _Slide(movie: widget.movies[index])),
          ),
        ),
      ]),
    );
  }
}

class _Slide extends ConsumerWidget {
  final Movie movie;
  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;
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

    return SizedBox(
      width: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(fit: StackFit.expand, children: [
                Positioned.fill(child: Material(color: Colors.transparent, child: InkWell(
                  onTap: () => context.push('/movie/${movie.id}'),
                  child: Image.network(movie.posterPath, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(color: colors.surfaceContainerHighest,
                      child: const Center(child: Icon(Icons.movie_outlined, size: 38))),
                  ),
                ))),
                const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black54],
                  stops: [0, 0.5, 1],
                )))),
                Positioned(top: 5, right: 5, child: Material(
                  color: Colors.black.withValues(alpha: 0.62), shape: const CircleBorder(),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    tooltip: isFavorite ? strings.removeFromFavorites : strings.addToFavorites,
                    onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
                    icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white),
                  ),
                )),
                Positioned(left: 6, right: 6, bottom: 6, child: IgnorePointer(child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SmallChip(icon: Icons.star_rounded, value: movie.voteAverage.toStringAsFixed(1)),
                    _SmallChip(value: ratingLabel),
                  ],
                ))),
              ]),
            ),
          ),
          const SizedBox(height: 7),
          Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 2),
          Text(movie.releaseDate.year > 1900 ? '${movie.releaseDate.year}' : '—',
            style: textStyles.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData? icon;
  final String value;
  const _SmallChip({this.icon, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(7)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) Icon(icon, color: const Color(0xFFFFC857), size: 13),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _Title extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final VoidCallback? onSeeAll;
  const _Title({this.title, this.subTitle, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 14, 10),
      child: Row(children: [
        if (title != null) Expanded(child: Text(title!, style: style?.copyWith(fontWeight: FontWeight.w900))),
        if (subTitle != null) onSeeAll != null
            ? TextButton(onPressed: onSeeAll, child: Text(subTitle!))
            : Text(subTitle!, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
