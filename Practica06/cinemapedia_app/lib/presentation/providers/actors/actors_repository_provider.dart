import 'package:cinemapedia_app/infrastructure/datasources/actor_moviedb_datasource.dart';
import 'package:cinemapedia_app/infrastructure/repositories/actor_repository_impl.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final actorsRepositoryProvider = Provider((ref) {
  final region = ref.watch(selectedMovieRegionProvider);
  final mode = ref.watch(contentModeProvider);
  return ActorRepositoryImpl(ActorMovieDbDatasource(
    region: region,
    isTv: mode == ContentMode.series,
  ));
});
