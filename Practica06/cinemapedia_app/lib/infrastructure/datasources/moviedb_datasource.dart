import 'package:cinemapedia_app/config/constants/environment.dart';
import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:dio/dio.dart';

class MoviedbDatasource extends MoviesDatasource {
  final MovieRegion region;
  final bool isTv;
  late final Dio dio;

  MoviedbDatasource({required this.region, this.isTv = false}) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': region.languageCode,
        'region': region.isoCode,
      },
    ));
  }

  String get _type => isTv ? 'tv' : 'movie';

  Movie _mapResult(Map<String, dynamic> json, {String certification = ''}) {
    final genreIds = (json['genre_ids'] as List<dynamic>? ?? const [])
        .map((value) => value.toString()).toList();
    final genreNames = (json['genres'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((genre) => (genre['name'] ?? '').toString())
        .where((name) => name.isNotEmpty).toList();
    final dateRaw = (json[isTv ? 'first_air_date' : 'release_date'] ?? '').toString();
    final title = (json[isTv ? 'name' : 'title'] ??
            json[isTv ? 'original_name' : 'original_title'] ?? 'Sin título')
        .toString();
    final poster = (json['poster_path'] ?? '').toString();
    final backdrop = (json['backdrop_path'] ?? '').toString();

    return Movie(
      adult: json['adult'] as bool? ?? false,
      backdropPath: backdrop.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w780$backdrop'
          : '',
      genreIds: genreIds,
      genreNames: genreNames,
      id: (json['id'] as num).toInt(),
      originalLanguage: (json['original_language'] ?? '').toString(),
      originalTitle: (json[isTv ? 'original_name' : 'original_title'] ?? title).toString(),
      overview: (json['overview'] ?? '').toString(),
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      posterPath: poster.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w500$poster'
          : '',
      releaseDate: DateTime.tryParse(dateRaw) ?? DateTime(1900),
      title: title,
      video: json['video'] as bool? ?? false,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      certification: certification,
      isTv: isTv,
    );
  }

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? const []);
    return results
        .whereType<Map<String, dynamic>>()
        .where((item) => (item['poster_path'] ?? '').toString().isNotEmpty)
        .map(_mapResult)
        .toList();
  }

  Future<List<Movie>> _getList(String endpoint, {int page = 1, Map<String, dynamic>? params}) async {
    final response = await dio.get(endpoint, queryParameters: {'page': page, ...?params});
    return _jsonToMovies(Map<String, dynamic>.from(response.data as Map));
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) => _getList(
        isTv ? '/tv/on_the_air' : '/movie/now_playing', page: page,
      );

  @override
  Future<List<Movie>> getPopular({int page = 1}) => _getList('/$_type/popular', page: page);

  @override
  Future<List<Movie>> getTopRated({int page = 1}) => _getList('/$_type/top_rated', page: page);

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    if (!isTv) return _getList('/movie/upcoming', page: page);

    // TMDB no ofrece un endpoint /tv/upcoming. Discover TV permite obtener
    // series con primera emisión dentro de los próximos seis meses.
    final today = DateTime.now();
    final horizon = today.add(const Duration(days: 180));
    return _getList('/discover/tv', page: page, params: {
      'first_air_date.gte': _dateOnly(today),
      'first_air_date.lte': _dateOnly(horizon),
      'sort_by': 'first_air_date.asc',
      'include_null_first_air_dates': false,
      'include_adult': false,
    });
  }

  String _movieCertification(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();
    if (isTv) {
      final country = results.where((item) => item['iso_3166_1'] == region.isoCode);
      if (country.isEmpty) return '';
      return (country.first['rating'] ?? '').toString().trim();
    }
    final country = results.where((item) => item['iso_3166_1'] == region.isoCode);
    if (country.isEmpty) return '';
    final releases = (country.first['release_dates'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();
    const preferredTypes = [3, 2, 4, 5, 6, 1];
    for (final type in preferredTypes) {
      for (final item in releases) {
        final value = (item['certification'] ?? '').toString().trim();
        if (item['type'] == type && value.isNotEmpty) return value;
      }
    }
    for (final item in releases) {
      final value = (item['certification'] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  /// Obtiene la clasificación regional que no viene incluida en los endpoints
  /// de listas (popular, now_playing, top_rated, etc.).
  @override
  Future<String> getCertification(String id) async {
    final ratingPath = isTv ? '/tv/$id/content_ratings' : '/movie/$id/release_dates';
    final ratingResponse = await dio.get(ratingPath);
    return _movieCertification(Map<String, dynamic>.from(ratingResponse.data as Map));
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final endpoint = '/$_type/$id';
    final response = await dio.get(endpoint);
    final data = Map<String, dynamic>.from(response.data as Map);

    // TMDB no siempre tiene sinopsis en todos los idiomas. Solo entonces se
    // consulta inglés y se usa como respaldo sin alterar el idioma elegido.
    if ((data['overview'] ?? '').toString().trim().isEmpty && region.languageCode != 'en-US') {
      try {
        final fallback = await dio.get(endpoint, queryParameters: {'language': 'en-US'});
        final fallbackData = Map<String, dynamic>.from(fallback.data as Map);
        if ((fallbackData['overview'] ?? '').toString().trim().isNotEmpty) {
          data['overview'] = fallbackData['overview'];
        }
        final nameKey = isTv ? 'name' : 'title';
        if ((data[nameKey] ?? '').toString().trim().isEmpty) data[nameKey] = fallbackData[nameKey];
      } catch (_) {}
    }

    var certification = '';
    try {
      certification = await getCertification(id);
    } catch (_) {
      // La ficha sigue disponible aunque TMDB no tenga clasificación regional.
    }

    return _mapResult(data, certification: certification);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    return _getList('/search/$_type', params: {
      'query': query.trim(),
      'include_adult': false,
    });
  }

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) => _getList(
        '/discover/$_type', page: page,
        params: {'with_genres': genreId, 'sort_by': 'popularity.desc', 'include_adult': false},
      );

  @override
  Future<List<Movie>> getSimilar(String id, {int page = 1}) =>
      _getList('/$_type/$id/similar', page: page);

  @override
  Future<String?> getTrailerKey(String id) async {
    final response = await dio.get('/$_type/$id/videos');
    final videos = (response.data['results'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((item) => item['site'] == 'YouTube' &&
            ['Trailer', 'Teaser'].contains(item['type']) &&
            (item['key'] ?? '').toString().trim().isNotEmpty)
        .toList();
    if (videos.isEmpty) return null;

    final language = region.languageCode.split('-').first;
    final localized = videos.where((item) => item['iso_639_1'] == language).toList();
    final english = videos.where((item) => item['iso_639_1'] == 'en').toList();
    final candidates = localized.isNotEmpty ? localized : (english.isNotEmpty ? english : videos);
    final official = candidates.where((item) => item['official'] == true).toList();
    final selected = official.isNotEmpty ? official.first : candidates.first;
    return selected['key'].toString();
  }
}
