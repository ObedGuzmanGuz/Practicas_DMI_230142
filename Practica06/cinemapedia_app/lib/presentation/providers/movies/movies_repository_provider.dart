import 'package:cinemapedia_app/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia_app/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';

final movieRepositoryProvider = Provider((ref) {
  final region = ref.watch(selectedMovieRegionProvider);
  final mode = ref.watch(contentModeProvider);
  return MovieRepositoryImpl(MoviedbDatasource(
    region: region,
    isTv: mode == ContentMode.series,
  ));
});
