import 'package:cinemapedia_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';

final movieInfoErrorsProvider = StateProvider<Map<String, String>>((ref) => {});

final movieInfoProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final repository = ref.watch(movieRepositoryProvider);
  return MovieMapNotifier(
    getMovie: repository.getMovieById,
    onLoadError: (id, message) => ref.read(movieInfoErrorsProvider.notifier).update((state) => {...state, id: message}),
    onSuccess: (id) => ref.read(movieInfoErrorsProvider.notifier).update((state) { final next = {...state}; next.remove(id); return next; }),
  );
});

typedef GetMovieCallback = Future<Movie> Function(String movieId);
typedef MovieLoadCallback = void Function(String id, String message);
typedef MovieSuccessCallback = void Function(String id);

class MovieMapNotifier extends StateNotifier<Map<String, Movie>> {
  final GetMovieCallback getMovie;
  final MovieLoadCallback onLoadError;
  final MovieSuccessCallback onSuccess;

  MovieMapNotifier({required this.getMovie, required this.onLoadError, required this.onSuccess}) : super({});

  Future<void> loadMovie(String movieId, {bool force = false}) async {
    if (!force && state[movieId] != null) return;
    try {
      final movie = await getMovie(movieId);
      state = {...state, movieId: movie};
      onSuccess(movieId);
    } catch (error) {
      onLoadError(movieId, error.toString());
    }
  }
}
