import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moviesByGenreProvider = FutureProvider.autoDispose.family<List<Movie>, int>(
  (ref, genreId) {
    final repository = ref.watch(movieRepositoryProvider);
    return repository.getMoviesByGenre(genreId);
  },
);
