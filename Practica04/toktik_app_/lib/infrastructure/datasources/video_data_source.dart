/// Contrato asíncrono para fuentes locales o remotas de video.
abstract interface class VideoDataSource {
  String get sourceName;
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12});
}
