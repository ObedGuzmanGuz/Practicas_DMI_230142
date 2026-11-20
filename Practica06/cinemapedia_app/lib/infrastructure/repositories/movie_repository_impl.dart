import 'package:cinemapedia_app/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia_app/domain/entities/movie.dart';
import 'package:cinemapedia_app/domain/repositories/movies_repository.dart';

class MovieRepositoryImpl extends MoviesRepository {
  final MoviesDatasource datasource;
  MovieRepositoryImpl(this.datasource);

  @override Future<List<Movie>> getNowPlaying({int page = 1}) => datasource.getNowPlaying(page: page);
  @override Future<List<Movie>> getPopular({int page = 1}) => datasource.getPopular(page: page);
  @override Future<List<Movie>> getTopRated({int page = 1}) => datasource.getTopRated(page: page);
  @override Future<List<Movie>> getUpcoming({int page = 1}) => datasource.getUpcoming(page: page);
  @override Future<Movie> getMovieById(String id) => datasource.getMovieById(id);
  @override Future<String> getCertification(String id) => datasource.getCertification(id);
  @override Future<List<Movie>> searchMovies(String query) => datasource.searchMovies(query);
  @override Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) => datasource.getMoviesByGenre(genreId, page: page);
  @override Future<List<Movie>> getSimilar(String id, {int page = 1}) => datasource.getSimilar(id, page: page);
  @override Future<String?> getTrailerKey(String id) => datasource.getTrailerKey(id);
}
