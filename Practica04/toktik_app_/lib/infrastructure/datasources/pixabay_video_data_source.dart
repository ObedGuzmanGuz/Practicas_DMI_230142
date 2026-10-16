import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:toktik_app/config/api_keys.dart';
import 'package:toktik_app/config/helpers/stable_video_id.dart';
import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';

/// Catálogo dinámico de Pixabay. Devuelve MP4 directos listos para video_player.
class PixabayVideoDataSource implements VideoDataSource {
  PixabayVideoDataSource({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  @override
  String get sourceName => 'Pixabay';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12}) async {
    if (ApiKeys.pixabay.isEmpty) return const [];
    final uri = Uri.https('pixabay.com', '/api/videos/', {
      'key': ApiKeys.pixabay,
      'page': '$page',
      'per_page': '${pageSize.clamp(3, 50)}',
      'safesearch': 'true',
      'order': 'popular',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      debugPrint('Pixabay respondió HTTP ${response.statusCode}: ${response.body}');
      throw Exception('Pixabay respondió HTTP ${response.statusCode}. Revisa la clave y el límite de solicitudes.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = (body['hits'] as List<dynamic>? ?? const []);
    return hits.whereType<Map<String, dynamic>>().map((hit) {
      final variants = hit['videos'] as Map<String, dynamic>? ?? const {};
      final medium = variants['medium'] as Map<String, dynamic>?;
      final small = variants['small'] as Map<String, dynamic>?;
      final large = variants['large'] as Map<String, dynamic>?;
      final url = (medium?['url'] as String?) ?? (small?['url'] as String?) ?? (large?['url'] as String?) ?? '';
      final id = hit['id'].toString();
      final tags = (hit['tags'] as String?) ?? 'Video de Pixabay';
      if (url.isEmpty) return <String, dynamic>{};
      return <String, dynamic>{
        'number': 400000000 + (stableVideoHash('pixabay:$id') % 100000000),
        'name': tags.split(',').take(3).join(' · '),
        'description': 'Video de Pixabay. Autor: ${hit['user'] ?? 'Comunidad Pixabay'}.',
        'fileId': 'pixabay_$id',
        'videoUrl': url,
        'source': 'Pixabay',
        'likes': (hit['likes'] as num?)?.toInt() ?? 100,
        'views': (hit['views'] as num?)?.toInt() ?? 1500,
        'usesEmbeddedPlayer': false,
      };
    }).where((item) => item.isNotEmpty).toList();
  }
}
