import 'package:flutter/foundation.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/domain/repositories/video_posts_repository.dart';
import 'package:toktik_app/infrastructure/datasources/drive_video_datasource_impl.dart';
import 'package:toktik_app/infrastructure/models/drive_video_model.dart';
import 'package:toktik_app/shared/data/drive_video_posts.dart';

class DiscoverProvider extends ChangeNotifier {
  final VideoPostRepository? videosRepository;

  bool initialLoading = true;
  bool muted = true;

  List<VideoPost> _videos = [];
  final Set<int> _seen = {};

  List<VideoPost> get videos => List.unmodifiable(_videos);

  DiscoverProvider({
    this.videosRepository,
  });

  void loadNextPage() {
    if (!initialLoading) return;

    // Para conservar la ejecución inmediata que utilizan
    // los tests de la práctica, cargamos el catálogo local.
    //
    // Los videos siguen alojados en Google Drive; aquí solamente
    // usamos sus IDs para construir las URLs.
    _videos = videoPosts
        .map(
          (data) => DriveVideoModel.fromJson(data).toVideoPostEntity(),
        )
        .map(
          (video) => video.copyWith(
            likes: 0,
            views: 0,
          ),
        )
        .toList();

    initialLoading = false;
    notifyListeners();
  }

  void toggleLike(int number) {
    final index = _videos.indexWhere(
      (video) => video.number == number,
    );

    if (index < 0) return;

    final video = _videos[index];

    _videos[index] = video.copyWith(
      likes: video.likes + (video.isLiked ? -1 : 1),
      isLiked: !video.isLiked,
    );

    notifyListeners();
  }

  void registerView(int number) {
    final index = _videos.indexWhere(
      (video) => video.number == number,
    );

    if (index < 0 || !_seen.add(number)) return;

    final video = _videos[index];

    _videos[index] = video.copyWith(
      views: video.views + 1,
    );

    notifyListeners();
  }

  void toggleMuted() {
    muted = !muted;
    notifyListeners();
  }
}