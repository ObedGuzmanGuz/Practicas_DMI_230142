import 'package:cinemapedia_app/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Evita mezclar clasificaciones cuando una película y una serie comparten ID.
final movieCertificationProvider = FutureProvider.family<
    String, ({int id, bool isTv})>((ref, media) {
  final region = ref.watch(selectedMovieRegionProvider);
  final datasource = MoviedbDatasource(region: region, isTv: media.isTv);
  return datasource.getCertification(media.id.toString());
});
