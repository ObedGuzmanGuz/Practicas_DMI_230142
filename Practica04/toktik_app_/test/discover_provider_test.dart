import 'package:flutter_test/flutter_test.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';

void main() {
  test('Catálogo completo, orden numérico y sin duplicar al recargar', () {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    provider.loadNextPage();
    expect(
      provider.videos.map((v) => v.number),
      List.generate(14, (i) => i + 1),
    );
    expect(provider.videos.map((v) => v.driveFileId).toSet(), hasLength(14));
    expect(provider.initialLoading, isFalse);
    for (final video in provider.videos) {
      expect(
        Uri.parse(video.videoUrl).queryParameters['id'],
        video.driveFileId,
      );
    }
  });
  test('Me gusta es reversible y se conserva al cambiar de video', () {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    provider.toggleLike(1);
    provider.toggleLike(2);
    expect(provider.videos.first.likes, 1);
    expect(provider.videos.first.isLiked, isTrue);
    provider.toggleLike(1);
    expect(provider.videos.first.likes, 0);
    expect(provider.videos.first.isLiked, isFalse);
    expect(provider.videos[1].isLiked, isTrue);
  });
  test(
    'Las vistas se cuentan una vez por sesión, sin inventar datos remotos',
    () {
      final provider = DiscoverProvider()..loadNextPage();
      addTearDown(provider.dispose);
      expect(provider.videos.first.views, 0);
      provider.registerView(1);
      provider.registerView(1);
      provider.registerView(999);
      expect(provider.videos.first.views, 1);
      expect(provider.videos[1].views, 0);
    },
  );
}
