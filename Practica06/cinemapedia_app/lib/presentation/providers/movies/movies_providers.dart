import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetch = ref.watch(movieRepositoryProvider).getNowPlaying;
  return MoviesNotifier(fetchMoreMovies: fetch);
});
final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetch = ref.watch(movieRepositoryProvider).getPopular;
  return MoviesNotifier(fetchMoreMovies: fetch);
});
final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetch = ref.watch(movieRepositoryProvider).getUpcoming;
  return MoviesNotifier(fetchMoreMovies: fetch);
});
final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetch = ref.watch(movieRepositoryProvider).getTopRated;
  return MoviesNotifier(fetchMoreMovies: fetch);
});

final movieSimilarProvider = FutureProvider.family<List<Movie>, String>((ref, movieId) {
  return ref.watch(movieRepositoryProvider).getSimilar(movieId);
});
final movieTrailerProvider = FutureProvider.family<String?, String>((ref, movieId) {
  return ref.watch(movieRepositoryProvider).getTrailerKey(movieId);
});

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;
  bool hasReachedEnd = false;
  bool hasAttempted = false;
  String? errorMessage;
  final MovieCallback fetchMoreMovies;

  MoviesNotifier({required this.fetchMoreMovies}) : super([]);

  Future<void> loadNextPage() async {
    if (isLoading || hasReachedEnd) return;
    isLoading = true;
    errorMessage = null;
    final nextPage = currentPage + 1;
    try {
      final movies = await fetchMoreMovies(page: nextPage);
      currentPage = nextPage;
      if (movies.isEmpty) {
        hasReachedEnd = true;
      } else {
        final existing = state.map((movie) => movie.id).toSet();
        state = [...state, ...movies.where((movie) => !existing.contains(movie.id))];
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      hasAttempted = true;
      isLoading = false;
      // Fuerza una notificación también cuando la petición termina con error.
      state = [...state];
    }
  }
}
