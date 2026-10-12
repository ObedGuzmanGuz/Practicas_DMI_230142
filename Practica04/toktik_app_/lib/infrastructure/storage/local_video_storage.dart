import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalVideoStorage {
  static const String _likedKey = 'toktik_liked_videos';
  static const String _viewsKey = 'toktik_video_views';

  Future<Set<int>> loadLikedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final values = prefs.getStringList(_likedKey) ?? <String>[];

      return values
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
    } catch (_) {
      return <int>{};
    }
  }

  Future<Map<int, int>> loadViews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_viewsKey);

      if (raw == null || raw.isEmpty) {
        return <int, int>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <int, int>{};
      }

      final result = <int, int>{};
      for (final entry in decoded.entries) {
        final number = int.tryParse(entry.key.toString());
        final value = entry.value;
        final views = value is int
            ? value
            : int.tryParse(value.toString());

        if (number != null && views != null && views >= 0) {
          result[number] = views;
        }
      }

      return result;
    } catch (_) {
      return <int, int>{};
    }
  }

  Future<void> saveState({
    required Set<int> likedVideos,
    required Map<int, int> views,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
        _likedKey,
        likedVideos.map((id) => id.toString()).toList(),
      );

      await prefs.setString(
        _viewsKey,
        jsonEncode(
          views.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        ),
      );
    } catch (_) {
      // El almacenamiento local no debe impedir que el video se reproduzca.
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_likedKey);
      await prefs.remove(_viewsKey);
    } catch (_) {}
  }
}
