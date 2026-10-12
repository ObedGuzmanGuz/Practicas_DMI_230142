import 'package:toktik_app/config/helpers/cloudinary_urls.dart';
import 'package:toktik_app/domain/entities/video_post.dart';

/// Mapper de JSON a entidad de dominio. Conserva el nombre histórico de la
/// práctica para no romper referencias existentes.
class DriveVideoModel {
  final int number;
  final String name;
  final String description;
  final String fileId;
  final String? sourceUrl;
  final String source;
  final int likes;
  final int views;
  final bool usesEmbeddedPlayer;

  const DriveVideoModel({
    required this.number,
    required this.name,
    this.description = '',
    required this.fileId,
    this.sourceUrl,
    this.source = 'Cloudinary',
    this.likes = 0,
    this.views = 0,
    this.usesEmbeddedPlayer = false,
  });

  factory DriveVideoModel.fromJson(Map<String, dynamic> json) {
    final number = json['number'];
    final name = json['name'];
    final fileId = json['fileId'];
    assert(number is int, 'number debe ser int');
    assert(name is String && name != '', 'name no puede estar vacío');
    assert(fileId is String && fileId != '', 'fileId no puede estar vacío');

    return DriveVideoModel(
      number: number as int,
      name: name as String,
      description: (json['description'] as String?) ?? '',
      fileId: fileId as String,
      sourceUrl: json['videoUrl'] as String?,
      source: (json['source'] as String?) ?? 'Cloudinary',
      likes: (json['likes'] as int?) ?? 0,
      views: (json['views'] as int?) ?? 0,
      usesEmbeddedPlayer: (json['usesEmbeddedPlayer'] as bool?) ?? false,
    );
  }

  VideoPost toVideoPostEntity() {
    final videoUrl = sourceUrl ?? CloudinaryUrls.video(fileId).toString();
    assert(Uri.tryParse(videoUrl)?.hasAbsolutePath == true,
        'La URL del video debe ser absoluta');

    return VideoPost(
      number: number,
      caption: name,
      description: description,
      driveFileId: fileId,
      videoUrl: videoUrl,
      source: source,
      likes: likes,
      views: views,
      initialLikes: likes,
      initialViews: views,
      usesEmbeddedPlayer: usesEmbeddedPlayer,
    );
  }
}
