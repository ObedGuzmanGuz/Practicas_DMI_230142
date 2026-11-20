import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get theMovieDbKey {
    try {
      return dotenv.env['THE_MOVIEDB_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }
}
