import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_by_genre_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
import 'package:cinemapedia_app/presentation/widgets/movies/movie_poster_card.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/custom_bottom_navigation.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/country_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  static const name = 'categories-screen';

  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int selectedGenreId = 28;

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(selectedMovieRegionProvider);
    final isSeries = ref.watch(contentModeProvider) == ContentMode.series;
    final strings = AppStrings(region);
    final genres = _genresFor(region.isoCode, isSeries: isSeries);
    final activeGenreId = genres.any((genre) => genre.id == selectedGenreId)
        ? selectedGenreId
        : genres.first.id;
    final moviesAsync = ref.watch(moviesByGenreProvider(activeGenreId));
    final selectedGenre = genres.firstWhere((genre) => genre.id == activeGenreId);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CountryDrawer(),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
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
            title: Text('${strings.categories} · ${isSeries ? strings.series : strings.movies}'),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.exploreGenres,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    strings.chooseGenre,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final genre = genres[index];
                  final selected = genre.id == activeGenreId;
                  return _GenreTile(
                    genre: genre,
                    selected: selected,
                    onTap: () => setState(() => selectedGenreId = genre.id),
                  );
                },
                childCount: genres.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 1.08,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 25, 16, 12),
              child: Row(
                children: [
                  Icon(selectedGenre.icon, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${strings.moviesFound}: ${selectedGenre.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          moviesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    strings.catalogLoadError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            data: (movies) => _moviesGrid(movies, strings),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _moviesGrid(List<Movie> movies, AppStrings strings) {
    if (movies.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(child: Text(strings.categoryEmpty)),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => MoviePosterCard(movie: movies[index]),
          childCount: movies.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
          childAspectRatio: 0.56,
        ),
      ),
    );
  }
}

class _Genre {
  final int id;
  final String name;
  final IconData icon;

  const _Genre(this.id, this.name, this.icon);
}

List<_Genre> _genresFor(String country, {bool isSeries = false}) {
  final isEnglish = country == 'US';
  final isJapanese = country == 'JP';
  final isGerman = country == 'DE';
  final isChinese = country == 'CN';
  final isArabic = country == 'SA';

  String t(String es, String en, String ja, String de, String zh, String ar) =>
      isEnglish ? en : isJapanese ? ja : isGerman ? de : isChinese ? zh : isArabic ? ar : es;

  if (isSeries) {
    return [
      _Genre(10759, t('Acción y aventura', 'Action & Adventure', 'アクション＆アドベンチャー', 'Action & Abenteuer', '动作冒险', 'أكشن ومغامرة'), Icons.explore_rounded),
      _Genre(16, t('Animación', 'Animation', 'アニメーション', 'Animation', '动画', 'رسوم متحركة'), Icons.movie_rounded),
      _Genre(35, t('Comedia', 'Comedy', 'コメディ', 'Komödie', '喜剧', 'كوميديا'), Icons.sentiment_very_satisfied_rounded),
      _Genre(80, t('Crimen', 'Crime', '犯罪', 'Krimi', '犯罪', 'جريمة'), Icons.policy_rounded),
      _Genre(99, t('Documental', 'Documentary', 'ドキュメンタリー', 'Dokumentation', '纪录片', 'وثائقي'), Icons.video_camera_back_rounded),
      _Genre(18, t('Drama', 'Drama', 'ドラマ', 'Drama', '剧情', 'دراما'), Icons.theaters),
      _Genre(10751, t('Familiar', 'Family', 'ファミリー', 'Familie', '家庭', 'عائلي'), Icons.family_restroom_rounded),
      _Genre(9648, t('Misterio', 'Mystery', 'ミステリー', 'Mystery', '悬疑', 'غموض'), Icons.visibility_rounded),
      _Genre(10765, t('Ciencia ficción y fantasía', 'Sci-Fi & Fantasy', 'SF・ファンタジー', 'Science-Fiction & Fantasy', '科幻奇幻', 'خيال علمي وفانتازيا'), Icons.auto_awesome_rounded),
      _Genre(10768, t('Guerra y política', 'War & Politics', '戦争・政治', 'Krieg & Politik', '战争政治', 'حرب وسياسة'), Icons.public_rounded),
    ];
  }

  return [
    _Genre(28, t('Acción', 'Action', 'アクション', 'Action', '动作', 'أكشن'), Icons.local_fire_department_rounded),
    _Genre(12, t('Aventura', 'Adventure', 'アドベンチャー', 'Abenteuer', '冒险', 'مغامرة'), Icons.explore_rounded),
    _Genre(16, t('Animación', 'Animation', 'アニメーション', 'Animation', '动画', 'رسوم متحركة'), Icons.movie_rounded),
    _Genre(35, t('Comedia', 'Comedy', 'コメディ', 'Komödie', '喜剧', 'كوميديا'), Icons.sentiment_very_satisfied_rounded),
    _Genre(80, t('Crimen', 'Crime', '犯罪', 'Krimi', '犯罪', 'جريمة'), Icons.policy_rounded),
    _Genre(18, t('Drama', 'Drama', 'ドラマ', 'Drama', '剧情', 'دراما'), Icons.theaters),
    _Genre(14, t('Fantasía', 'Fantasy', 'ファンタジー', 'Fantasy', '奇幻', 'خيال'), Icons.auto_awesome_rounded),
    _Genre(27, t('Terror', 'Horror', 'ホラー', 'Horror', '恐怖', 'رعب'), Icons.nights_stay_rounded),
    _Genre(878, t('Ciencia ficción', 'Science fiction', 'SF', 'Science-Fiction', '科幻', 'خيال علمي'), Icons.rocket_launch_rounded),
    _Genre(53, t('Suspenso', 'Thriller', 'スリラー', 'Thriller', '惊悚', 'تشويق'), Icons.visibility_rounded),
    _Genre(10749, t('Romance', 'Romance', 'ロマンス', 'Romanze', '爱情', 'رومانسي'), Icons.favorite_rounded),
    _Genre(99, t('Documental', 'Documentary', 'ドキュメンタリー', 'Dokumentation', '纪录片', 'وثائقي'), Icons.video_camera_back_rounded),
  ];
}

class _GenreTile extends StatelessWidget {
  final _Genre genre;
  final bool selected;
  final VoidCallback onTap;

  const _GenreTile({
    required this.genre,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.35),
              width: selected ? 1.6 : 0.7,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                genre.icon,
                size: 27,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 7),
              Text(
                genre.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? colors.onPrimaryContainer : colors.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
