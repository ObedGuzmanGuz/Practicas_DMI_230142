import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:toktik_app/config/api_keys.dart';
import 'package:toktik_app/config/helpers/stable_video_id.dart';
import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';

/// Catálogo dinámico de Coverr; la API devuelve URLs MP4 firmadas.
class CoverrVideoDataSource implements VideoDataSource {
  CoverrVideoDataSource({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  @override
  String get sourceName => 'Coverr';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({int page = 1, int pageSize = 12}) async {
    if (ApiKeys.coverr.isEmpty) return const [];
    final uri = Uri.https('api.coverr.co', '/videos', {
      'page': '${page - 1}',
      'page_size': '${pageSize.clamp(1, 20)}',
      'urls': 'true',
    });
    final response = await _client.get(uri, headers: {'Authorization': 'Bearer ${ApiKeys.coverr}'}).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      debugPrint('Coverr respondió HTTP ${response.statusCode}: ${response.body}');
      throw Exception('Coverr respondió HTTP ${response.statusCode}. Revisa la clave y el acceso de tu API.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = (body['hits'] as List<dynamic>? ?? const []);
    return hits.whereType<Map<String, dynamic>>().map((hit) {
      final urls = hit['urls'] as Map<String, dynamic>? ?? const {};
      final url = (urls['mp4_preview'] as String?) ?? (urls['mp4'] as String?) ?? '';
      final id = (hit['id'] ?? hit['slug'] ?? '').toString();
      if (url.isEmpty || id.isEmpty) return <String, dynamic>{};
      final title = (hit['title'] as String?) ?? 'Video de Coverr';
      final tags = hit['tags'];
      return <String, dynamic>{
        'number': 500000000 + (stableVideoHash('coverr:$id') % 100000000),
        'name': title,
        'description': (hit['description'] as String?) ?? 'Video de Coverr. Etiquetas: ${tags is List ? tags.join(', ') : ''}',
        'fileId': 'coverr_$id',
        'videoUrl': url,
        'source': 'Coverr',
        'likes': 250 + stableVideoHash('coverr-likes:$id') % 9000,
        'views': 1200 + stableVideoHash('coverr-views:$id') % 80000,
        'usesEmbeddedPlayer': false,
      };
    }).where((item) => item.isNotEmpty).toList();
  }
}
