import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik_app/config/theme/app_theme.dart';
import 'package:toktik_app/main.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  final streams = <int, StreamController<VideoEvent>>{};
  final sources = <DataSource>[];
  final playing = <int>{};
  final disposed = <int>{};
  final volumes = <int, double>{};
  bool fail = false;
  bool hold = false;
  int _next = 0;
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    sources.add(options.dataSource);
    final id = _next++;
    streams[id] = StreamController<VideoEvent>(onCancel: () async {});
    return id;
  }

  void initialize(int id) => streams[id]!.add(
    VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(seconds: 20),
      size: const Size(720, 1280),
    ),
  );
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    scheduleMicrotask(() {
      if (fail) {
        streams[playerId]!.addError(
          PlatformException(code: 'network-test', message: 'Simulated offline'),
        );
      } else if (!hold) {
        initialize(playerId);
      }
    });
    return streams[playerId]!.stream;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
    playing.remove(playerId);
    await streams[playerId]!.close();
  }

  @override
  Future<void> play(int playerId) async {
    playing.add(playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    playing.remove(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes[playerId] = volume;
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> seekTo(int playerId, Duration position) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) async {}
  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black);
}

void main() {
  late FakeVideoPlatform platform;
  late VideoPlayerPlatform original;
  setUp(() {
    original = VideoPlayerPlatform.instance;
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });
  tearDown(() {
    VideoPlayerPlatform.instance = original;
  });

  Future<void> flush(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> clean(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
  }

  Widget player({bool active = true, VoidCallback? onFirstPlay}) => MaterialApp(
    theme: AppTheme().getTheme(),
    home: Scaffold(
      body: FullScreenPlayer(
        videoUrl: 'https://example.com/test.mp4',
        driveFileId: 'test',
        active: active,
        muted: true,
        onFirstPlay: onFirstPlay ?? () {},
      ),
    ),
  );

  testWidgets('La app usa Cloudinary, muestra 14 videos', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await flush(tester);
    expect(find.text('TOKTIK AZUL'), findsOneWidget);
    expect(find.text('1 / 14'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('TOKTIK AZUL')).style!.color,
      AppTheme.accent,
    );
    expect(platform.sources, hasLength(1));
    expect(platform.sources.single.sourceType, DataSourceType.network);
    expect(
         platform.sources.single.uri,
         'https://res.cloudinary.com/ryzcssnd/video/upload/video_1.mp4',
);
    expect(platform.playing, {0});
    expect(platform.volumes[0], 0);
    await clean(tester);
  });

  testWidgets('Al deslizar se libera el reproductor anterior', (tester) async {
    await tester.pumpWidget(const MyApp());
    await flush(tester);
    await tester.drag(find.byType(PageView), const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('2 / 14'), findsOneWidget);
    expect(platform.disposed, contains(0));
    expect(platform.playing.length, 1);
    expect(platform.playing.contains(0), isFalse);
    await clean(tester);
  });

  testWidgets('Pausa al salir y conserva la pausa manual al volver', (
    tester,
  ) async {
    await tester.pumpWidget(player());
    await flush(tester);
    expect(platform.playing, {0});
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await flush(tester);
    expect(platform.playing, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await flush(tester);
    expect(platform.playing, {0});
    await tester.tap(find.byType(GestureDetector).first);
    await flush(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await flush(tester);
    expect(platform.playing, isEmpty);
    await clean(tester);
  });

  testWidgets('Los errores permiten reintentar sin registrar una vista', (
    tester,
  ) async {
    platform.fail = true;
    int views = 0;
    await tester.pumpWidget(player(onFirstPlay: () => views++));
    await flush(tester);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(views, 0);
    platform.fail = false;
    await tester.tap(find.text('Reintentar'));
    await flush(tester);
    expect(platform.playing.length, 1);
    expect(views, 1);
    await clean(tester);
  });

  testWidgets('Salir durante la carga cancela la espera y libera el video', (
    tester,
  ) async {
    platform.hold = true;
    await tester.pumpWidget(player());
    await flush(tester);
    await tester.pumpWidget(player(active: false));
    await flush(tester);
    expect(platform.playing, isEmpty);
    expect(platform.disposed, contains(0));
    expect(tester.takeException(), isNull);
    await clean(tester);
  });
}
