import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';

/// Catálogo de Vimeo a través de player.vimeo.com.
class VimeoVideoDataSource implements VideoDataSource {
  @override
  String get sourceName => 'Vimeo';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12}) async => const [
        {
          'number': 201,
          'name': 'Big Buck Bunny · Vimeo',
          'description': 'Cortometraje de animación disponible en Vimeo. La reproducción se delega al reproductor embebido del proveedor y el feed conserva sus estadísticas simuladas.',
          'fileId': 'vimeo_1084537',
          'videoUrl': 'https://player.vimeo.com/video/1084537?autoplay=1&muted=1&title=0&byline=0&playsinline=1',
          'source': 'Vimeo',
          'likes': 9270,
          'views': 146800,
          'usesEmbeddedPlayer': true,
        },
      ];
}
