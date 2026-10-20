import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';
import 'package:toktik_app/infrastructure/repositories/composite_video_repository.dart';
import 'package:toktik_app/infrastructure/storage/local_settings_storage.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Catálogo base conserva las fuentes embebidas y el catálogo principal', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(
      provider.videos.map((v) => v.number),
      containsAll([1, 2, 101, 201, 301]),
    );

    expect(provider.videos.map((v) => v.driveFileId).toSet().length, greaterThanOrEqualTo(17));
    expect(provider.videos.map((v) => v.source).toSet(),
        containsAll({'Cloudinary', 'YouTube', 'Vimeo', 'Dailymotion'}));
    expect(
      provider.videos.map((v) => Uri.parse(v.videoUrl).host).toSet(),
      containsAll({'res.cloudinary.com', 'www.youtube.com', 'player.vimeo.com', 'geo.dailymotion.com'}),
    );

    expect(provider.initialLoading, isFalse);

    for (final video in provider.videos) {
      expect(Uri.tryParse(video.videoUrl)?.hasAbsolutePath, isTrue);
      expect(video.description, isNotEmpty);
    }
    for (final video in provider.videos.where((v) => v.source == 'Cloudinary')) {
      expect(video.videoUrl, 'https://res.cloudinary.com/ryzcssnd/video/upload/${video.driveFileId}.mp4');
      expect(video.usesEmbeddedPlayer, isFalse);
    }
    expect(provider.videos.take(2).every((v) => !v.usesEmbeddedPlayer), isTrue);
    expect(provider.videos.skip(2).take(3).every((v) => v.usesEmbeddedPlayer), isTrue);
    expect(provider.videos.where((v) => v.source == 'Pixabay' || v.source == 'Coverr').every((v) => !v.usesEmbeddedPlayer), isTrue);
  });

  test('Todos los videos arrancan con likes y vistas simulados', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    for (final video in provider.videos) {
      expect(video.likes, greaterThan(0));
      expect(video.views, greaterThan(0));
      expect(video.views, greaterThanOrEqualTo(video.likes));
      expect(video.isLiked, isFalse);
    }
  });

  test('Like suma uno y desmarcarlo resta uno sin borrar likes simulados', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final initialLikes = provider.videos.first.likes;

    provider.toggleLike(1);
    expect(provider.videos.first.likes, initialLikes + 1);
    expect(provider.videos.first.isLiked, isTrue);

    provider.toggleLike(1);
    expect(provider.videos.first.likes, initialLikes);
    expect(provider.videos.first.isLiked, isFalse);
  });

  test('Las vistas aumentan cada vez que el video termina', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final initialViews = provider.videos.first.views;

    provider.registerView(1);
    provider.registerView(1);
    provider.registerView(1);

    expect(provider.videos.first.views, initialViews + 3);
    expect(provider.videos[1].views, greaterThan(0));
  });

  test('El like personal se suma una sola vez por video', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final initialLikes = provider.videos.first.likes;

    provider.toggleLike(1);
    provider.toggleLike(1);
    provider.toggleLike(1);

    expect(provider.videos.first.likes, initialLikes + 1);
    expect(provider.videos.first.isLiked, isTrue);
  });

  test('For You y Favorites reflejan los likes locales', () async {
    final provider = DiscoverProvider()..loadNextPage();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(seconds: 1));

    provider.registerView(1);
    provider.toggleLike(1);

    expect(provider.favoritesCount, 1);
    expect(provider.favoritesVideos.single.number, 1);
    expect(provider.favoritesVideos.single.isLiked, isTrue);
    expect(provider.forYouVideos.first.number, 1);
  });

  test('Las vistas se restauran desde almacenamiento local', () async {
    final first = DiscoverProvider()..loadNextPage();
    addTearDown(first.dispose);

    final firstInitialViews = first.videos.first.views;
    final firstInitialLikes = first.videos.first.likes;
    first.registerView(1);
    first.toggleLike(1);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = DiscoverProvider()..loadNextPage();
    addTearDown(second.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(second.videos.first.views, firstInitialViews + 1);
    expect(second.videos.first.likes, firstInitialLikes + 1);
    expect(second.videos.first.isLiked, isTrue);
  });

  test('La temporada automática respeta el rango de Halloween y las cuatro opciones', () {
    expect(seasonForDate(DateTime(2026, 1, 10)), AppSeason.normal);
    expect(seasonForDate(DateTime(2026, 10, 2)), AppSeason.normal);
    expect(seasonForDate(DateTime(2026, 10, 9)), AppSeason.normal);
    expect(seasonForDate(DateTime(2026, 10, 27)), AppSeason.normal);
    expect(seasonForDate(DateTime(2026, 10, 28)), AppSeason.halloween);
    expect(seasonForDate(DateTime(2026, 11, 2)), AppSeason.halloween);
    expect(seasonForDate(DateTime(2026, 11, 3)), AppSeason.normal);
    expect(seasonForDate(DateTime(2026, 12, 5)), AppSeason.christmas);
    expect(seasonForDate(DateTime(2026, 12, 24)), AppSeason.christmas);
    expect(seasonForDate(DateTime(2026, 2, 14)), AppSeason.valentinesDay);
  });

  test('La primera preferencia de tema es Normal', () async {
    final storage = LocalSettingsStorage();
    expect(await storage.loadSeasonMode(), 'normal');
  });

  test('La preferencia de temporada se conserva en almacenamiento local', () async {
    final storage = LocalSettingsStorage();
    await storage.saveSeasonMode('halloween');
    expect(await storage.loadSeasonMode(), 'halloween');
  });

}
