import 'package:cinemapedia_app/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:dio/dio.dart';

import 'package:cinemapedia_app/config/constants/environment.dart';
import 'package:cinemapedia_app/domain/datasources/movies_datasource.dart';

import 'package:cinemapedia_app/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia_app/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';


class MoviedbDatasource extends MoviesDatasource {

  final MovieRegion region;
  late final Dio dio;

  MoviedbDatasource({required this.region}) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': region.languageCode,
        'region': region.isoCode,
      },
    ));
  }

  List<Movie> _jsonToMovies( Map<String,dynamic> json ) {

    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
    .where((moviedb) => moviedb.posterPath != 'no-poster' )
    .map(
      (moviedb) => MovieMapper.movieDBToEntity(moviedb)
    ).toList();

    return movies;

  }


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    
    final response = await dio.get('/movie/now_playing', 
      queryParameters: {
        'page': page
      }
    );
    
    return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
     
    final response = await dio.get('/movie/popular', 
      queryParameters: {
        'page': page
      }
    );

    return _jsonToMovies(response.data);    
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
     
    final response = await dio.get('/movie/top_rated', 
      queryParameters: {
        'page': page
      }
    );

    return _jsonToMovies(response.data);    
  }

   @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
     
    final response = await dio.get('/movie/upcoming', 
      queryParameters: {
        'page': page
      }
    );

    return _jsonToMovies(response.data);    
  }


  String _certificationForSelectedRegion(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? const []);
    final countryResults = results.cast<Map<String, dynamic>>().where(
      (country) => country['iso_3166_1'] == region.isoCode,
    );

    if (countryResults.isEmpty) return '';

    final releaseDates = (countryResults.first['release_dates'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    // Prioriza la clasificación del estreno en cines y utiliza otra fecha
    // del mismo país como alternativa si ese registro no incluye certificado.
    const preferredTypes = [3, 2, 4, 5, 6, 1];
    for (final type in preferredTypes) {
      for (final release in releaseDates) {
        final certification = (release['certification'] ?? '').toString().trim();
        if (release['type'] == type && certification.isNotEmpty) {
          return certification;
        }
      }
    }

    for (final release in releaseDates) {
      final certification = (release['certification'] ?? '').toString().trim();
      if (certification.isNotEmpty) return certification;
    }

    return '';
  }

  @override
  Future<Movie> getMovieById( String id ) async {

    final response = await dio.get('/movie/$id');
    if ( response.statusCode != 200 ) throw Exception('Movie with id: $id not found');
    
    final movieDetails = MovieDetails.fromJson(response.data);
    var certification = '';

    // Si el servicio regional no responde, la ficha sigue mostrándose y
    // solamente se indica que la clasificación no está disponible.
    try {
      final releasesResponse = await dio.get('/movie/$id/release_dates');
      certification = _certificationForSelectedRegion(releasesResponse.data);
    } catch (_) {
      certification = '';
    }

    return MovieMapper.movieDetailsToEntity(
      movieDetails,
      certification: certification,
    );
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async{

    if ( query.isEmpty ) return [];

    final response = await dio.get('/search/movie', 
      queryParameters: {
        'query': query
      }
    );

    return _jsonToMovies(response.data);    
  }


}