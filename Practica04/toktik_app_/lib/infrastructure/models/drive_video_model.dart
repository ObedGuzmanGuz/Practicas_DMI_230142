import 'package:toktik_app/config/helpers/drive_urls.dart';
import 'package:toktik_app/domain/entities/video_post.dart';

class DriveVideoModel {
  final int number;
  final String name;
  final String fileId;
  final int likes;
  final int views;

  const DriveVideoModel({
    required this.number,
    required this.name,
    required this.fileId,
    this.likes = 0,
    this.views = 0,
  });

  factory DriveVideoModel.fromJson(Map<String, dynamic> json) {
    return DriveVideoModel(
      number: json['number'] as int,
      name: json['name'] as String,
      fileId: json['fileId'] as String,
      likes: (json['likes'] as int?) ?? 0,
      views: (json['views'] as int?) ?? 0,
    );
  }

  VideoPost toVideoPostEntity() {
    return VideoPost(
      number: number,
      caption: name,
      driveFileId: fileId,
      videoUrl: DriveUrls.download(fileId).toString(),
      likes: likes,
      views: views,
    );
  }
}