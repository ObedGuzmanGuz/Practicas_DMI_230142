import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:toktik_app/config/api_keys.dart';
import 'package:toktik_app/config/helpers/stable_video_id.dart';
import 'package:toktik_app/infrastructure/datasources/video_data_source.dart';

/// Busca candidatos a YouTube Shorts. La API entrega metadatos; el video se
/// reproduce con el reproductor oficial incrustado, sin sus controles visibles.
/// YouTube Data API no expone una propiedad que garantice la orientación vertical;
/// la búsqueda #shorts y el filtro de duración reducen videos largos/no relacionados.
class YouTubeVideoDataSource implements VideoDataSource {
  YouTubeVideoDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<int, String> _pageTokens = <int, String>{};

  @override
  String get sourceName => 'YouTube';

  @override
  Future<List<Map<String, dynamic>>> fetchVideos({
    int page = 1,
    int pageSize = 12,
  }) async {
    if (ApiKeys.youtube.isEmpty) return const <Map<String, dynamic>>[];

    // videoDuration=short filtra a menos de 4 minutos en la API de búsqueda.
    // Luego videos.list aplica el límite de Shorts actual de 3 minutos.
    final params = <String, String>{
      'key': ApiKeys.youtube,
      'part': 'snippet',
      'q': '#shorts',
      'type': 'video',
      'videoEmbeddable': 'true',
      // Además de ser insertables, deben permitir reproducción sindicada fuera
      // de youtube.com para reducir videos que el reproductor rechaza.
      'videoSyndicated': 'true',
      'videoDuration': 'short',
      'safeSearch': 'moderate',
      'regionCode': 'MX',
      'order': 'date',
      // Solicita más resultados porque después se filtran duración e IDs repetidos.
      'maxResults': '50',
    };
    if (page > 1) {
      final token = _pageTokens[page];
      if (token == null || token.isEmpty) return const <Map<String, dynamic>>[];
      params['pageToken'] = token;
    }

    final searchUri = Uri.https('www.googleapis.com', '/youtube/v3/search', params);
    final searchResponse = await _client
        .get(searchUri)
        .timeout(const Duration(seconds: 12));
    if (searchResponse.statusCode != 200) {
      throw Exception(_youtubeError(searchResponse.statusCode, searchResponse.body));
    }

    final searchBody = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final nextToken = searchBody['nextPageToken'] as String?;
    if (nextToken == null || nextToken.isEmpty) {
      _pageTokens.remove(page + 1);
    } else {
      _pageTokens[page + 1] = nextToken;
    }

    final candidates = <Map<String, dynamic>>[];
    for (final item in (searchBody['items'] as List<dynamic>? ?? const [])) {
      if (item is! Map<String, dynamic>) continue;
      final idData = item['id'];
      final snippet = item['snippet'];
      if (idData is! Map<String, dynamic> || snippet is! Map<String, dynamic>) continue;
      final id = idData['videoId'] as String?;
      if (id == null || id.isEmpty) continue;

      final title = (snippet['title'] as String? ?? 'YouTube Short')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final description = (snippet['description'] as String? ?? '').trim();
      final channel = (snippet['channelTitle'] as String? ?? 'YouTube').trim();
      candidates.add(<String, dynamic>{
        'number': 600000000 + (stableVideoHash('youtube:$id') % 100000000),
        'name': title.isEmpty ? 'YouTube Short' : title,
        'description': description.isEmpty
            ? 'Publicado por $channel en YouTube Shorts.'
            : '$description\n\nCanal: $channel',
        'fileId': 'youtube_$id',
        'videoUrl': 'https://www.youtube.com/embed/$id?autoplay=1&mute=1&controls=0&playsinline=1&rel=0&enablejsapi=1&fs=0&disablekb=1&iv_load_policy=3',
        'source': 'YouTube',
        'likes': 0,
        'views': 0,
        'usesEmbeddedPlayer': true,
        '_youtubeId': id,
      });
    }

    if (candidates.isEmpty) return const <Map<String, dynamic>>[];

    // Los resultados de search.list ya están filtrados a videos cortos e insertables.
    // videos.list agrega duración/estadísticas como mejora, pero si esa segunda llamada
    // falla no se debe dejar el feed vacío.
    try {
      final ids = candidates.map((item) => item['_youtubeId'] as String).join(',');
      final detailsUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
        'key': ApiKeys.youtube,
        'part': 'contentDetails,statistics,status',
        'id': ids,
      });
      final detailsResponse = await _client
          .get(detailsUri)
          .timeout(const Duration(seconds: 10));
      if (detailsResponse.statusCode != 200) {
        debugPrint(_youtubeError(detailsResponse.statusCode, detailsResponse.body));
        return _prepareFallbackCandidates(candidates, pageSize);
      }

      final details = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final detailsById = <String, Map<String, dynamic>>{};
      for (final item in (details['items'] as List<dynamic>? ?? const [])) {
        if (item is Map<String, dynamic> && item['id'] is String) {
          detailsById[item['id'] as String] = item;
        }
      }

      final shorts = <Map<String, dynamic>>[];
      for (final video in candidates) {
        final id = video['_youtubeId'] as String;
        final item = detailsById[id];
        if (item == null) continue;
        // Confirma en el recurso de video que la inserción esté habilitada;
        // la búsqueda por sí sola puede devolver contenido que luego no se reproduce.
        final status = item['status'];
        if (status is! Map<String, dynamic> || status['embeddable'] != true) continue;

        final contentDetails = item['contentDetails'];
        if (contentDetails is! Map<String, dynamic>) continue;
        final duration = _parseIsoDurationSeconds(contentDetails['duration'] as String?);
        // Prioriza Shorts de hasta tres minutos; la API no expone su orientación.
        if (duration == null || duration <= 0 || duration > 180) continue;

        final stats = item['statistics'];
        if (stats is Map<String, dynamic>) {
          video['views'] = int.tryParse('${stats['viewCount'] ?? 0}') ?? 0;
          video['likes'] = int.tryParse('${stats['likeCount'] ?? 0}') ?? 0;
        }
        video.remove('_youtubeId');
        shorts.add(video);
        if (shorts.length >= pageSize.clamp(1, 50)) break;
      }
      return shorts;
    } catch (error) {
      debugPrint('No se pudieron obtener duración/estadísticas de YouTube: $error');
      return _prepareFallbackCandidates(candidates, pageSize);
    }
  }

  List<Map<String, dynamic>> _prepareFallbackCandidates(
    List<Map<String, dynamic>> candidates,
    int pageSize,
  ) {
    final fallback = <Map<String, dynamic>>[];
    for (final original in candidates) {
      final video = Map<String, dynamic>.from(original);
      video.remove('_youtubeId');
      fallback.add(video);
      if (fallback.length >= pageSize.clamp(1, 50)) break;
    }
    return fallback;
  }

  int? _parseIsoDurationSeconds(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').firstMatch(value);
    if (match == null) return null;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    return hours * 3600 + minutes * 60 + seconds;
  }

  String _youtubeError(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return 'YouTube Data API respondió HTTP $statusCode: $message';
        }
      }
    } catch (_) {
      // Conserva un mensaje útil aunque Google no entregue un JSON esperado.
    }
    return 'YouTube Data API respondió HTTP $statusCode. Verifica la clave y que YouTube Data API v3 esté habilitada.';
  }
}
