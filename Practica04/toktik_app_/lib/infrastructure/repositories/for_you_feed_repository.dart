import 'package:toktik_app/domain/entities/video_post.dart';

/// Para ti contiene solo los resultados de YouTube Data API. Conserva el orden
/// de YouTube (relevancia/popularidad) para que un contador nuevo no mueva el
/// video que se está reproduciendo.
class ForYouFeedRepository {
  List<VideoPost> getFeed(List<VideoPost> videos) => List<VideoPost>.unmodifiable(
        videos.where((video) => video.source == 'YouTube'),
      );
}
