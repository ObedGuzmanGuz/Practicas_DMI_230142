import 'package:toktik_app/domain/entities/video_post.dart';

/// Contrato de acceso a las fuentes y las reglas de los tres feeds.
abstract interface class VideoRepository {
  Future<List<VideoPost>> getDiscoverVideos({int page = 1});

  Future<List<VideoPost>> getYouTubeVideos({int page = 1});

  List<VideoPost> getForYouVideos(List<VideoPost> videos);

  List<VideoPost> getFavoriteVideos(List<VideoPost> videos);
}
