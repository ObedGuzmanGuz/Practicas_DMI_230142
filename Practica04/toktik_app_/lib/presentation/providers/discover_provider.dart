import 'package:flutter/foundation.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/infrastructure/models/drive_video_model.dart';
import 'package:toktik_app/shared/data/drive_video_posts.dart';

class DiscoverProvider extends ChangeNotifier {
  bool initialLoading = true;
  bool muted = true;
  List<VideoPost> _videos = [];
  final Set<int> _seen = {};
  List<VideoPost> get videos => List.unmodifiable(_videos);
  // Catálogo finito: repetir esta llamada no duplica los videos.
  void loadNextPage() {
  if (!initialLoading) return;

  _videos = videoPosts
      // Convertir los mapas del catálogo a modelos.
      .map((data) => DriveVideoModel.fromJson(data))

      // Incluir únicamente videos cuyos likes no superen sus vistas.
      .where((video) => video.likes <= video.views)

      // Convertir los videos aceptados a entidades para la pantalla.
      .map((video) => video.toVideoPostEntity())

      .toList();

  initialLoading = false;
  notifyListeners();
}

  void toggleLike(int number) {
    final index = _videos.indexWhere((video) => video.number == number);
    if (index < 0) return;
    final video = _videos[index];
    _videos[index] = video.copyWith(
      likes: video.likes + (video.isLiked ? -1 : 1),
      isLiked: !video.isLiked,
    );
    notifyListeners();
  }

  // Se cuenta al iniciar la reproducción, una vez por video y sesión.
  // No son estadísticas de Google Drive ni de otros usuarios.
  void registerView(int number) {
    final index = _videos.indexWhere((video) => video.number == number);
    if (index < 0 || !_seen.add(number)) return;
    _videos[index] = _videos[index].copyWith(views: _videos[index].views + 1);
    notifyListeners();
  }

  void toggleMuted() {
    muted = !muted;
    notifyListeners();
  }
}
