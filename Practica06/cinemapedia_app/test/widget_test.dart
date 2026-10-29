import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/main.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia_app/presentation/widgets/shared/custom_bottom_navigation.dart';

void main() {
  testWidgets('Cinemapedia muestra la navegación principal sin conexión a TMDB',
      (WidgetTester tester) async {
    final testMovie = Movie(
      adult: false,
      backdropPath: '',
      genreIds: const [],
      id: 1,
      originalLanguage: 'es',
      originalTitle: 'Película de prueba',
      overview: 'Película utilizada únicamente para la prueba.',
      popularity: 1,
      posterPath: 'https://example.com/poster.jpg',
      releaseDate: DateTime(2024, 1, 1),
      title: 'Película de prueba',
      video: false,
      voteAverage: 8,
      voteCount: 10,
    );

    MoviesNotifier notifier() => MoviesNotifier(
          fetchMoreMovies: ({int page = 1}) async => [testMovie],
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowPlayingMoviesProvider.overrideWith((ref) => notifier()),
          popularMoviesProvider.overrideWith((ref) => notifier()),
          topRatedMoviesProvider.overrideWith((ref) => notifier()),
          upcomingMoviesProvider.overrideWith((ref) => notifier()),
        ],
        child: const MainApp(),
      ),
    );

    expect(find.byType(CustomBottomNavigation), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
