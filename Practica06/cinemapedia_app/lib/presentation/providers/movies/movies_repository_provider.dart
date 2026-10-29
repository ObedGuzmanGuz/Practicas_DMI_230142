import 'package:cinemapedia_app/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia_app/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';

// Se recrea cuando cambia el país, por lo que todas las consultas usan
// el idioma y la región seleccionados.
final movieRepositoryProvider = Provider((ref) {
  final region = ref.watch(selectedMovieRegionProvider);
  return MovieRepositoryImpl(MoviedbDatasource(region: region));
});
