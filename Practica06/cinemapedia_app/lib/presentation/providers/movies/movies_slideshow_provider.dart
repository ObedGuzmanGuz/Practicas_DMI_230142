import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';

import 'movies_providers.dart';




final moviesSlideshowProvider = Provider<List<Movie>>((ref){
  
  final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

  if ( nowPlayingMovies.isEmpty ) return [];

  return nowPlayingMovies.take(6).toList();

});