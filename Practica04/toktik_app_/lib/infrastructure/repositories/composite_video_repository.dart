import 'package:flutter/foundation.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/domain/repositories/video_repository.dart';
import 'package:toktik_app/infrastructure/datasources/cloudinary_video_data_source.dart';
import 'package:toktik_app/infrastructure/datasources/coverr_video_data_source.dart';
import 'package:toktik_app/infrastructure/datasources/pixabay_video_data_source.dart';
import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';
import 'package:toktik_app/infrastructure/datasources/youtube_video_data_source.dart';
import 'package:toktik_app/infrastructure/mappers/video_post_mapper.dart';
import 'package:toktik_app/infrastructure/repositories/favorites_feed_repository.dart';
import 'package:toktik_app/infrastructure/repositories/for_you_feed_repository.dart';

/// Reparte las fuentes en dos flujos: Descubrir (MP4 y plataformas distintas
/// de YouTube) y Para ti (YouTube Data API exclusivamente). Un fallo temporal
/// de una fuente no bloquea las demás.
class CompositeVideoRepository implements VideoRepository {
  CompositeVideoRepository({
    List<VideoDataSource>? dataSources,
    ForYouFeedRepository? forYouRepository,
    FavoritesFeedRepository? favoritesRepository,
  })  : _dataSources = dataSources ?? <VideoDataSource>[
          CloudinaryVideoDataSource(),
          PixabayVideoDataSource(),
          CoverrVideoDataSource(),
          YouTubeVideoDataSource(),
        ],
        _forYouRepository = forYouRepository ?? ForYouFeedRepository(),
        _favoritesRepository = favoritesRepository ?? FavoritesFeedRepository();

  final List<VideoDataSource> _dataSources;
  final VideoPostMapper _mapper = const VideoPostMapper();
  final ForYouFeedRepository _forYouRepository;
  final FavoritesFeedRepository _favoritesRepository;

  @override
  Future<List<VideoPost>> getDiscoverVideos({int page = 1}) async {
    assert(_dataSources.isNotEmpty, 'Debe existir al menos un datasource.');
    final sources = _dataSources.where((source) {
      if (source.sourceName == 'YouTube') return false;
      if (page == 1) return true;
      // Solo las fuentes que admiten paginación aportan más contenido.
      return source.sourceName == 'Pixabay' || source.sourceName == 'Coverr';
    }).toList();
    final batches = await Future.wait(sources.map((source) async {
      try {
        return await source.fetchVideos(page: page, pageSize: 12);
      } catch (error) {
        debugPrint('Fuente ${source.sourceName} no disponible: $error');
        return <Map<String, dynamic>>[];
      }
    }));
    return _mapUnique(batches);
  }

  @override
  Future<List<VideoPost>> getYouTubeVideos({int page = 1}) async {
    final source = _dataSources.where((item) => item.sourceName == 'YouTube');
    if (source.isEmpty) return const <VideoPost>[];
    try {
      final records = await source.first.fetchVideos(page: page, pageSize: 12);
      return _mapUnique(<List<Map<String, dynamic>>>[records]);
    } catch (error) {
      debugPrint('No se pudieron cargar videos de YouTube: $error');
      // No sustituye el feed de YouTube por videos de otra fuente.
      return const <VideoPost>[];
    }
  }

  List<VideoPost> _mapUnique(List<List<Map<String, dynamic>>> batches) {
    final result = <VideoPost>[];
    final usedNumbers = <int>{};
    final usedIds = <String>{};
    for (final batch in batches) {
      for (final json in batch) {
        final post = _mapper.fromJson(json);
        assert(post.videoUrl.isNotEmpty, 'Cada video debe tener una URL.');
        if (!usedNumbers.add(post.number) || !usedIds.add(post.driveFileId)) continue;
        result.add(post);
      }
    }
    return List<VideoPost>.unmodifiable(result);
  }

  @override
  List<VideoPost> getForYouVideos(List<VideoPost> videos) =>
      _forYouRepository.getFeed(videos);

  @override
  List<VideoPost> getFavoriteVideos(List<VideoPost> videos) =>
      _favoritesRepository.getFeed(videos);
}
