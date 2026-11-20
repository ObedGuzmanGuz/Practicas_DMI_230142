import 'package:cinemapedia_app/config/constants/environment.dart';
import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia_app/domain/entities/actor.dart';
import 'package:cinemapedia_app/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia_app/infrastructure/models/moviedb/credits_response.dart';
import 'package:dio/dio.dart';

class ActorMovieDbDatasource extends ActorsDatasource {
  final MovieRegion region;
  final bool isTv;
  late final Dio dio;

  ActorMovieDbDatasource({required this.region, this.isTv = false}) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {'api_key': Environment.theMovieDbKey, 'language': region.languageCode},
    ));
  }

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {
    final response = await dio.get('/${isTv ? 'tv' : 'movie'}/$movieId/credits');
    final castResponse = CreditsResponse.fromJson(response.data);
    return castResponse.cast.map(ActorMapper.castToEntity).toList();
  }
}
