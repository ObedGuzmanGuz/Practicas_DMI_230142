import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/models/drive_video_model.dart';

/// Convierte la estructura cruda de cualquier datasource a la entidad usada
/// por presentación. Centraliza el mapeo para evitar lógica en los widgets.
class VideoPostMapper {
  const VideoPostMapper();

  VideoPost fromJson(Map<String, dynamic> json) =>
      DriveVideoModel.fromJson(json).toVideoPostEntity();
}
