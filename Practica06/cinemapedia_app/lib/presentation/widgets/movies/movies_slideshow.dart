import 'dart:async';
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

class MoviesSlideshow extends ConsumerStatefulWidget {
  final List<Movie> movies;
  const MoviesSlideshow({super.key, required this.movies});
  @override
  ConsumerState<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends ConsumerState<MoviesSlideshow> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  Timer? _autoplay;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  @override
  void didUpdateWidget(covariant MoviesSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movies.length != oldWidget.movies.length ||
        (widget.movies.isNotEmpty && oldWidget.movies.isNotEmpty &&
            widget.movies.first.id != oldWidget.movies.first.id)) {
      _activeIndex = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
      _startAutoplay();
    }
  }

  void _startAutoplay() {
    _autoplay?.cancel();
    if (widget.movies.length < 2) return;
    _autoplay = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_activeIndex + 1) % widget.movies.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 550), curve: Curves.easeInOutCubic);
    });
  }

  void _goTo(int index) {
    if (widget.movies.isEmpty || !_controller.hasClients) return;
    _controller.animateToPage(index.clamp(0, widget.movies.length - 1).toInt(),
        duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _autoplay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox(height: 255);
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings(ref.watch(selectedMovieRegionProvider));
    return SizedBox(
      height: 270,
      child: Column(children: [
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.movies.length,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (context, index) => _Slide(movie: widget.movies[index]),
            ),
            Positioned(left: 20, child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              tooltip: strings.previousCarousel,
              onTap: () => _goTo(_activeIndex - 1),
              onDoubleTap: () => _goTo(0),
            )),
            Positioned(right: 20, child: _ArrowButton(
              icon: Icons.chevron_right_rounded,
              tooltip: strings.nextCarousel,
              onTap: () => _goTo(_activeIndex + 1),
              onDoubleTap: () => _goTo(widget.movies.length - 1),
            )),
          ]),
        ),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var index = 0; index < widget.movies.length; index++)
            GestureDetector(
              onTap: () => _goTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _activeIndex ? 19 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: index == _activeIndex ? colors.primary : colors.secondary.withValues(alpha: 0.42),
                ),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  const _ArrowButton({required this.icon, required this.tooltip, required this.onTap, required this.onDoubleTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.black.withValues(alpha: 0.58),
      shape: const CircleBorder(),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, color: Colors.white, size: 29)),
      ),
    ),
  );
}

class _Slide extends ConsumerWidget {
  final Movie movie;
  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteMoviesProvider.select(
      (items) => items.any((item) => item.id == movie.id && item.isTv == movie.isTv),
    ));
    final colors = Theme.of(context).colorScheme;
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);
    final certification = ref.watch(movieCertificationProvider((id: movie.id, isTv: movie.isTv)));
    final ratingLabel = certification.when(
      data: (value) => ContentRatingLabels.compact(value, region.isoCode),
      loading: () => '···',
      error: (_, __) => ContentRatingLabels.compact(movie.certification, region.isoCode),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(fit: StackFit.expand, children: [
          Positioned.fill(child: Material(color: Colors.transparent, child: InkWell(
            onTap: () => context.push('/movie/${movie.id}'),
            child: Image.network(movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(color: colors.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.movie_outlined, size: 46))),
              loadingBuilder: (context, child, progress) => progress == null ? FadeIn(child: child)
                : const ColoredBox(color: Colors.black12),
            ),
          ))),
          const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87], stops: [0.2, 1],
          )))),
          Positioned(right: 10, top: 10, child: _FavoriteButton(movie: movie, isFavorite: isFavorite)),
          Positioned(left: 17, right: 17, bottom: 12, child: GestureDetector(
            onTap: () => context.push('/movie/${movie.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(movie.overview.isNotEmpty ? movie.overview : ' ', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.88))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC857), size: 15),
                  const SizedBox(width: 3),
                  Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFFFC857), fontWeight: FontWeight.bold)),
                  const Spacer(),
                  _RatingChip(value: ratingLabel),
                ]),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final Movie movie;
  final bool isFavorite;
  const _FavoriteButton({required this.movie, required this.isFavorite});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(selectedMovieRegionProvider));
    return Material(
    color: Colors.black.withValues(alpha: 0.6), shape: const CircleBorder(),
    child: IconButton(
      tooltip: isFavorite ? strings.removeFromFavorites : strings.addToFavorites,
      onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
      icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white),
    ),
  );
  }
}

class _RatingChip extends StatelessWidget {
  final String value;
  const _RatingChip({required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(7)),
    child: Text(value.isEmpty ? 'NR' : value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
  );
}
