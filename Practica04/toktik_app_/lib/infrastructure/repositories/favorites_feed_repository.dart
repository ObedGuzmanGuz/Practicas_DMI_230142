import 'package:toktik_app/domain/entities/video_post.dart';

/// Repositorio local del feed Favorites.
class FavoritesFeedRepository {
  List<VideoPost> getFeed(List<VideoPost> videos) => List.unmodifiable(
        videos.where((video) => video.isLiked).toList(),
      );
}
