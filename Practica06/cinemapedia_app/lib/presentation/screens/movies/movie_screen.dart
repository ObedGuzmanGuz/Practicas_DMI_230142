import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/config/helpers/content_rating_labels.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/actors/actors_by_movie_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/favorite_movies_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/movie_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MovieScreen extends ConsumerStatefulWidget {
  static const name = 'movie-screen';
  final String movieId;
  const MovieScreen({super.key, required this.movieId});

  @override
  ConsumerState<MovieScreen> createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MovieScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load(force: true);
      });
    }
  }

  void _load({bool force = false}) {
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId, force: force);
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedMovieRegionProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _load(force: true); });
    });
    ref.listen(contentModeProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _load(force: true); });
    });
    final Movie? movie = ref.watch(movieInfoProvider)[widget.movieId];
    final error = ref.watch(movieInfoErrorsProvider)[widget.movieId];
    final region = ref.watch(selectedMovieRegionProvider);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: error == null
          ? const CircularProgressIndicator(strokeWidth: 2)
          : Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_rounded, size: 54),
                const SizedBox(height: 12),
                Text(AppStrings(ref.watch(selectedMovieRegionProvider)).detailLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: () => _load(force: true), icon: const Icon(Icons.refresh_rounded), label: Text(AppStrings(ref.watch(selectedMovieRegionProvider)).retry)),
              ]),
            )),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverToBoxAdapter(child: _MovieDetails(movie: movie, region: region)),
        ],
      ),
    );
  }
}

class _MovieDetails extends ConsumerWidget {
  final Movie movie;
  final MovieRegion region;
  const _MovieDetails({required this.movie, required this.region});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final strings = AppStrings(region);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final actors = ref.watch(actorsByMovieProvider)[movie.id.toString()] ?? const [];
    final trailer = ref.watch(movieTrailerProvider(movie.id.toString()));
    final similar = ref.watch(movieSimilarProvider(movie.id.toString()));
    final genreLabels = movie.genreNames.isNotEmpty ? movie.genreNames : movie.genreIds;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LayoutBuilder(builder: (context, constraints) {
              final badge = _ClassificationBadge(
                value: ContentRatingLabels.compact(movie.certification, region.isoCode),
              );
              final title = Text(
                movie.title,
                maxLines: constraints.maxWidth < 330 ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              );
              if (constraints.maxWidth < 330) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 8), Align(alignment: Alignment.centerRight, child: badge)],
                );
              }
              return Row(children: [Expanded(child: title), const SizedBox(width: 8), badge]);
            }),
            const SizedBox(height: 9),
            MovieStarRating(ratingOutOfTen: movie.voteAverage, iconSize: 21),
            const SizedBox(height: 13),
            Row(children: [
              Icon(Icons.calendar_month_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 7),
              Expanded(child: Text(
                '${strings.releaseDate}: ${movie.releaseDate.year > 1900 ? '${movie.releaseDate.day.toString().padLeft(2, '0')}/${movie.releaseDate.month.toString().padLeft(2, '0')}/${movie.releaseDate.year}' : '—'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
            ]),
            const SizedBox(height: 11),
            Text('${strings.classification} · ${region.menuLabel}', style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(ContentRatingLabels.detail(movie.certification, region.isoCode),
              style: text.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Text(strings.genres, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Wrap(spacing: 7, runSpacing: 4, children: genreLabels.map((genre) => Chip(
              label: Text(genre), visualDensity: VisualDensity.compact, side: BorderSide.none,
              backgroundColor: colors.primaryContainer,
            )).toList()),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: (size.width * 0.29).clamp(76.0, 118.0).toDouble(),
              height: 178,
              child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(
                movie.posterPath, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(color: colors.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.movie_outlined))),
              )),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(movie.overview.isNotEmpty ? movie.overview : strings.noOverview,
              style: text.bodyMedium?.copyWith(height: 1.45))),
          ]),
        ),
        _SectionHeading(title: strings.trailer, icon: Icons.play_circle_fill_rounded),
        trailer.when(
          loading: () => const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _EmptyInfo(text: strings.noTrailer),
          data: (key) => key == null ? _EmptyInfo(text: strings.noTrailer) : _TrailerPlayer(key: ValueKey<String>('trailer-${movie.id}-$key'), videoId: key, region: region),
        ),
        _SectionHeading(title: strings.cast, icon: Icons.people_alt_rounded),
        if (actors.isEmpty)
          _EmptyInfo(text: strings.noCast)
        else
          SizedBox(height: 245, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];
              return Container(
                width: 128, padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(
                    actor.profilePath, width: 112, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 112, color: colors.surfaceContainerHighest,
                      child: const Icon(Icons.person_rounded, size: 42)),
                  ))),
                  const SizedBox(height: 6),
                  Text(actor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                  Text(actor.character ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                ]),
              );
            },
          )),
        _SectionHeading(title: strings.similar, icon: Icons.auto_awesome_rounded),
        similar.when(
          loading: () => const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, __) => _EmptyInfo(text: strings.similarLoadError),
          data: (items) => items.isEmpty ? _EmptyInfo(text: strings.noSimilar)
            : SizedBox(height: 255, child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) => SizedBox(width: 145, child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _SimilarCard(movie: items[index]),
                )),
              )),
        ),
      ]),
    );
  }
}

class _TrailerPlayer extends StatefulWidget {
  final String videoId;
  final MovieRegion region;
  const _TrailerPlayer({super.key, required this.videoId, required this.region});
  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  late final YoutubePlayerController _controller = YoutubePlayerController.fromVideoId(
    videoId: widget.videoId,
    autoPlay: false,
    params: YoutubePlayerParams(
      showControls: true,
      showFullscreenButton: true,
      privacyEnhancedMode: true,
      interfaceLanguage: widget.region.languageCode.split('-').first,
      captionLanguage: widget.region.languageCode.split('-').first,
      // El origen debe ser el de la app (localhost/GitHub Pages/dominio),
      // no el dominio del iframe de YouTube.
      origin: kIsWeb ? Uri.base.origin : null,
    ),
  );

  Future<void> _openOnYoutube() async {
    final uri = Uri.https('www.youtube.com', '/watch', {'v': widget.videoId});
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir YouTube en este dispositivo.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir YouTube en este dispositivo.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.region);
    final width = (MediaQuery.sizeOf(context).width - 28).clamp(180.0, 900.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.trailerFallback, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: _openOnYoutube,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(strings.watchOnYoutube),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarCard extends StatelessWidget {
  final Movie movie;
  const _SimilarCard({required this.movie});
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap: () => context.push('/movie/${movie.id}'),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(
        movie.posterPath, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12, child: Icon(Icons.movie_outlined)),
      ))),
      const SizedBox(height: 6),
      Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
      Text('★ ${movie.voteAverage.toStringAsFixed(1)}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFFFFB84D))),
    ]),
  );
}

class _CustomSliverAppBar extends ConsumerWidget {
  final Movie movie;
  const _CustomSliverAppBar({required this.movie});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(selectedMovieRegionProvider));
    final isFavorite = ref.watch(favoriteMoviesProvider.select((items) =>
      items.any((item) => item.id == movie.id && item.isTv == movie.isTv),
    ));
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.black,
      expandedHeight: MediaQuery.sizeOf(context).height * 0.56,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: isFavorite ? strings.removeFromFavorites : strings.addToFavorites,
          onPressed: () => ref.read(favoriteMoviesProvider.notifier).toggle(movie),
          icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? const Color(0xFFFF6B9A) : Colors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
        Image.network(movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black, child: Center(child: Icon(Icons.movie_outlined, color: Colors.white, size: 48))),
          loadingBuilder: (context, child, progress) => progress == null ? FadeIn(child: child) : const ColoredBox(color: Colors.black),
        ),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [0.35, 1], colors: [Colors.transparent, Colors.black87],
        ))),
        Positioned(left: 18, right: 18, bottom: 18, child: Text(movie.title, maxLines: 2,
          overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900))),
      ])),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeading({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 9),
    child: Row(children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
    ]),
  );
}

class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}

class _ClassificationBadge extends StatelessWidget {
  final String value;
  const _ClassificationBadge({required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
    child: Text(value.isEmpty ? 'NR' : value, style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w900)),
  );
}
