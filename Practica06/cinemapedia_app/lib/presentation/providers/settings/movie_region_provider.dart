import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedMovieRegionProvider = StateNotifierProvider<MovieRegionNotifier, MovieRegion>(
  (ref) => MovieRegionNotifier(),
);

class MovieRegionNotifier extends StateNotifier<MovieRegion> {
  bool _userChanged = false;

  MovieRegionNotifier() : super(movieRegions.first) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = SharedPreferencesAsync();
      final iso = await prefs.getString('cinemapedia_region');
      if (!mounted || _userChanged || iso == null) return;
      state = movieRegions.firstWhere(
        (region) => region.isoCode == iso,
        orElse: () => movieRegions.first,
      );
    } catch (_) {}
  }

  Future<void> setRegion(MovieRegion region) async {
    _userChanged = true;
    state = region;
    try {
      await SharedPreferencesAsync().setString('cinemapedia_region', region.isoCode);
    } catch (_) {}
  }
}
