import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';
import 'package:toktik_app/shared/data/drive_video_posts.dart';

/// Catálogo principal alojado en la cuenta Cloudinary de la práctica.
class CloudinaryVideoDataSource implements VideoDataSource {
  @override
  String get sourceName => 'Cloudinary';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12}) async =>
      videoPosts.map((video) => Map<String, dynamic>.from(video)).toList();
}
