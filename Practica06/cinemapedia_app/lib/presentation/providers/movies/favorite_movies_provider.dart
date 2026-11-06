import 'dart:convert';

import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoriteMoviesProvider =
    StateNotifierProvider<FavoriteMoviesNotifier, List<Movie>>(
  (ref) => FavoriteMoviesNotifier(),
);

class FavoriteMoviesNotifier extends StateNotifier<List<Movie>> {
  late final Future<void> _ready;

  FavoriteMoviesNotifier() : super(const []) {
    _ready = _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final preferences = SharedPreferencesAsync();
      final saved = await preferences.getString('cinemapedia_favorite_movies');
      if (saved == null || saved.isEmpty) return;

      final decoded = jsonDecode(saved) as List<dynamic>;
      final movies = decoded
          .whereType<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList();
      if (mounted) state = movies;
    } catch (_) {
      if (mounted) state = const [];
    }
  }

  bool isFavorite(int movieId) => state.any((movie) => movie.id == movieId);

  Future<void> toggle(Movie movie) async {
    await _ready;
    final exists = state.any((item) => item.id == movie.id);
    state = exists
        ? state.where((item) => item.id != movie.id).toList()
        : [movie, ...state];
    await _saveFavorites();
  }

  Future<void> remove(int movieId) async {
    await _ready;
    state = state.where((movie) => movie.id != movieId).toList();
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    try {
      final preferences = SharedPreferencesAsync();
      final encoded = jsonEncode(state.map((movie) => movie.toJson()).toList());
      await preferences.setString('cinemapedia_favorite_movies', encoded);
    } catch (_) {
      // Los favoritos permanecen en memoria si el almacenamiento no está disponible.
    }
  }
}
