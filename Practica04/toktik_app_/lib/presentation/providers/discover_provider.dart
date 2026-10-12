import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/domain/repositories/video_repository.dart';
import 'package:toktik_app/infrastructure/repositories/composite_video_repository.dart';
import 'package:toktik_app/infrastructure/storage/local_video_storage.dart';

class DiscoverProvider extends ChangeNotifier {
  DiscoverProvider({LocalVideoStorage? storage, VideoRepository? repository})
      : _storage = storage ?? LocalVideoStorage(),
        _repository = repository ?? CompositeVideoRepository();

  final LocalVideoStorage _storage;
  final VideoRepository _repository;
  bool initialLoading = true;
  bool loadingMore = false;
  int _nextPage = 2;
  bool hasMore = true;
  bool muted = true;
  List<VideoPost> _videos = <VideoPost>[];
  Set<int> _likedVideos = <int>{};
  final Set<int> _interactedVideos = <int>{};

  /// Descubrir muestra todas las fuentes excepto YouTube.
  List<VideoPost> get videos => List<VideoPost>.unmodifiable(
        _videos.where((video) => video.source != 'YouTube'),
      );

  List<VideoPost> get favoritesVideos => _repository.getFavoriteVideos(_videos);
  int get favoritesCount => favoritesVideos.length;
  List<VideoPost> get forYouVideos => _repository.getForYouVideos(_videos);

  Future<void> loadNextPage() async {
    if (!initialLoading) return;
    try {
      final pages = await Future.wait<List<VideoPost>>([
        _repository.getDiscoverVideos(page: 1),
        _repository.getYouTubeVideos(page: 1),
      ]);
      _videos = <VideoPost>[...pages[0], ...pages[1]]
          .map((video) => video.copyWith(isLiked: false))
          .toList();
      _nextPage = 2;
      hasMore = true;
    } catch (error) {
      debugPrint('No se pudieron cargar las fuentes de video: $error');
      _videos = <VideoPost>[];
    } finally {
      initialLoading = false;
      notifyListeners();
    }
    unawaited(_restoreLocalState());
  }

  /// Añade páginas de Pixabay, Coverr y YouTube sin mezclar sus feeds en UI.
  Future<void> loadMoreVideos() async {
    if (loadingMore || !hasMore || initialLoading) return;
    loadingMore = true;
    notifyListeners();
    try {
      final pages = await Future.wait<List<VideoPost>>([
        _repository.getDiscoverVideos(page: _nextPage),
        _repository.getYouTubeVideos(page: _nextPage),
      ]);
      final existingIds = _videos.map((video) => video.driveFileId).toSet();
      final unique = <VideoPost>[];
      for (final pageVideos in pages) {
        for (final video in pageVideos) {
          if (existingIds.add(video.driveFileId)) unique.add(video);
        }
      }
      if (unique.isEmpty) {
        hasMore = false;
      } else {
        _videos = <VideoPost>[..._videos, ...unique];
        _nextPage++;
        unawaited(_restoreLocalState());
      }
    } catch (error) {
      debugPrint('No se pudieron cargar más videos: $error');
      // El feed actual sigue disponible y permite volver a intentarlo.
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _restoreLocalState() async {
    final liked = await _storage.loadLikedVideos();
    final storedViews = await _storage.loadViews();
    _likedVideos = liked;
    _videos = _videos.map((video) {
      // No descartar acciones ocurridas mientras se leía SharedPreferences.
      if (_interactedVideos.contains(video.number)) return video;
      final views = max(video.initialViews, storedViews[video.number] ?? video.initialViews);
      final isLiked = liked.contains(video.number);
      return video.copyWith(
        views: views,
        likes: video.initialLikes + (isLiked ? 1 : 0),
        isLiked: isLiked,
      );
    }).toList();

    for (final video in _videos.where((video) => _interactedVideos.contains(video.number))) {
      if (video.isLiked) {
        _likedVideos.add(video.number);
      } else {
        _likedVideos.remove(video.number);
      }
    }
    notifyListeners();
    if (_interactedVideos.isNotEmpty) unawaited(_saveLocalState());
  }

  void toggleLike(int number) {
    final index = _videos.indexWhere((video) => video.number == number);
    if (index < 0) return;
    final video = _videos[index];
    _interactedVideos.add(number);
    final nowLiked = !video.isLiked;
    final likes = nowLiked ? video.likes + 1 : max(video.initialLikes, video.likes - 1);
    _videos[index] = video.copyWith(likes: likes, isLiked: nowLiked);
    if (nowLiked) {
      _likedVideos.add(number);
    } else {
      _likedVideos.remove(number);
    }
    notifyListeners();
    unawaited(_saveLocalState());
  }

  /// Se llama cuando el reproductor realmente empieza a reproducir el video.
  /// YouTube reporta cada transición a PLAYING; los MP4, cada inicio de play.
  void registerView(int number) {
    final index = _videos.indexWhere((video) => video.number == number);
    if (index < 0) return;
    final video = _videos[index];
    _interactedVideos.add(number);
    _videos[index] = video.copyWith(views: video.views + 1);
    notifyListeners();
    unawaited(_saveLocalState());
  }

  Future<void> _saveLocalState() => _storage.saveState(
        likedVideos: _likedVideos,
        views: {for (final video in _videos) video.number: video.views},
      );

  void toggleMuted() {
    muted = !muted;
    notifyListeners();
  }
}
