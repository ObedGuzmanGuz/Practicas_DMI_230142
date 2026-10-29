import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// País inicial de la aplicación. Al cambiarlo se recrean los proveedores
/// que consultan películas para cargar los datos del nuevo país e idioma.
final selectedMovieRegionProvider = StateProvider<MovieRegion>(
  (ref) => movieRegions.first,
);
