import 'package:toktik_app/domain/datasources/video_posts_datasource.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/models/drive_video_model.dart';
import 'package:toktik_app/shared/data/drive_video_posts.dart';

class DriveVideoDatasource implements VideoPostDatasource {
  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    return [];
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    final List<VideoPost> videos = videoPosts
        .map(
          (video) => DriveVideoModel.fromJson(video).toVideoPostEntity(),
        )
        .toList();

    return videos;
  }
}