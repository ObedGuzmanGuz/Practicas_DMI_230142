import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';

/// Catálogo de Dailymotion a través de su reproductor embebido.
class DailymotionVideoDataSource implements VideoDataSource {
  @override
  String get sourceName => 'Dailymotion';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12}) async => const [
        {
          'number': 301,
          'name': 'Big Buck Bunny · Dailymotion',
          'description': 'Un corto animado disponible en Dailymotion. La app utiliza la URL de embed para reproducir desde la plataforma en lugar de intentar tratarla como un archivo MP4 directo.',
          'fileId': 'dailymotion_x6nqmd',
          'videoUrl': 'https://geo.dailymotion.com/player/x8lr5.html?video=x6nqmd&autoplay=true&mute=true',
          'source': 'Dailymotion',
          'likes': 6410,
          'views': 103500,
          'usesEmbeddedPlayer': true,
        },
      ];
}
