import 'package:toktik_app/config/helpers/drive_urls.dart';
import 'package:toktik_app/domain/entities/video_post.dart';

class DriveVideoModel {
  final int number;
  final String name;
  final String fileId;
  const DriveVideoModel({
    required this.number,
    required this.name,
    required this.fileId,
  });
  factory DriveVideoModel.fromJson(Map<String, dynamic> json) =>
      DriveVideoModel(
        number: json['number'] as int,
        name: json['name'] as String,
        fileId: json['fileId'] as String,
      );
  VideoPost toVideoPostEntity() => VideoPost(
    number: number,
    caption: name,
    driveFileId: fileId,
    videoUrl: DriveUrls.download(fileId).toString(),
  );
}
