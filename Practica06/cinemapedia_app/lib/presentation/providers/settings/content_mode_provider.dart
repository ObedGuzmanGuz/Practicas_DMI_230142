import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ContentMode { movies, series }

final contentModeProvider = StateNotifierProvider<ContentModeNotifier, ContentMode>(
  (ref) => ContentModeNotifier(),
);

class ContentModeNotifier extends StateNotifier<ContentMode> {
  bool _userChanged = false;

  ContentModeNotifier() : super(ContentMode.movies) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final value = await SharedPreferencesAsync().getString('cinemapedia_content_mode');
      if (!mounted || _userChanged) return;
      state = value == 'series' ? ContentMode.series : ContentMode.movies;
    } catch (_) {}
  }

  Future<void> setMode(ContentMode mode) async {
    _userChanged = true;
    state = mode;
    try {
      await SharedPreferencesAsync().setString(
        'cinemapedia_content_mode',
        mode == ContentMode.series ? 'series' : 'movies',
      );
    } catch (_) {}
  }
}
