import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String driveFileId;
  final bool active;
  final bool muted;
  final VoidCallback onPlaybackStarted;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.driveFileId,
    required this.active,
    required this.muted,
    required this.onPlaybackStarted,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  VoidCallback? _controllerListener;
  bool _loading = false;
  String? _error;
  bool _foreground = true;
  bool _wantsToPlay = true;
  bool _completionReported = false;
  bool _playbackReported = false;
  int _generation = 0;
  Completer<void>? _cancelInitialization;

  bool get _supported =>
      kIsWeb ||
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (widget.active) {
      _initialize();
    }
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.active) {
      _release();
    } else if (!oldWidget.active || oldWidget.videoUrl != widget.videoUrl) {
      _wantsToPlay = true;
      _initialize();
    } else if (oldWidget.muted != widget.muted) {
      unawaited(_synchronize());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    unawaited(_synchronize());
  }

  bool _isCurrent(VideoPlayerController controller, int generation) =>
      mounted &&
      generation == _generation &&
      identical(_controller, controller);

  Future<void> _close(
    VideoPlayerController controller,
    VoidCallback? listener,
  ) async {
    if (listener != null) {
      controller.removeListener(listener);
    }

    try {
      if (controller.value.isInitialized) {
        await controller.pause();
      }
    } catch (_) {
      // Un fallo de pausa no debe impedir liberar recursos.
    }

    try {
      await controller.dispose();
    } catch (error) {
      debugPrint('No se pudo liberar el reproductor: $error');
    }
  }

  void _release() {
    _generation++;

    final cancellation = _cancelInitialization;
    _cancelInitialization = null;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }

    final previous = _controller;
    final previousListener = _controllerListener;

    _controller = null;
    _controllerListener = null;
    _completionReported = false;

    if (previous != null) {
      unawaited(_close(previous, previousListener));
    }
  }

  Future<void> _initialize() async {
    _release();
    _error = null;
    _completionReported = false;
    _playbackReported = false;

    if (!_supported) {
      _loading = false;
      _error =
          'Ejecuta la app en Android, iOS, macOS o Chrome/Edge. '
          'Este reproductor no admite Windows/Linux como aplicación de escritorio.';
      if (mounted) setState(() {});
      return;
    }

    _loading = true;
    if (mounted) setState(() {});

    final generation = _generation;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _controller = controller;

    final listener = () => _handleVideoProgress(controller, generation);
    _controllerListener = listener;
    controller.addListener(listener);

    final cancellation = Completer<void>();
    _cancelInitialization = cancellation;

    try {
      await Future.any<void>([
        controller.initialize(),
        cancellation.future,
      ]).timeout(const Duration(seconds: 45));

      if (!_isCurrent(controller, generation)) return;

      await controller.setLooping(false);
      if (!_isCurrent(controller, generation)) return;

      if (mounted) {
        setState(() => _loading = false);
      }

      await _synchronize();
    } catch (_) {
      if (!_isCurrent(controller, generation)) return;

      _release();
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'No se pudo cargar el video. Revisa tu conexión y que la fuente '
              'remota entregue un MP4 compatible.';
        });
      }
    }
  }

  void _handleVideoProgress(
    VideoPlayerController controller,
    int generation,
  ) {
    if (!_isCurrent(controller, generation)) return;
    if (!controller.value.isInitialized) return;

    final value = controller.value;

    if (value.isCompleted && !_completionReported) {
      _completionReported = true;
      unawaited(_restartAfterCompletion(controller, generation));
    }
  }

  Future<void> _restartAfterCompletion(
    VideoPlayerController controller,
    int generation,
  ) async {
    if (!_isCurrent(controller, generation)) return;

    try {
      await controller.seekTo(Duration.zero);
      if (!_isCurrent(controller, generation)) return;

      _completionReported = false;
      _playbackReported = false;
      _wantsToPlay = true;
      await _synchronize();
    } catch (_) {
      // Si no puede reiniciar, queda detenido en el final del video.
    }
  }

  Future<void> _synchronize() async {
    final controller = _controller;
    final generation = _generation;

    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setVolume(widget.muted ? 0 : 1);
      if (!_isCurrent(controller, generation)) return;

      if (widget.active && _foreground && _wantsToPlay) {
        await controller.play();
        if (!_isCurrent(controller, generation)) return;
        if (!_playbackReported) {
          _playbackReported = true;
          widget.onPlaybackStarted();
        }

        if (!widget.active || !_foreground || !_wantsToPlay) {
          await controller.pause();
        }
      } else {
        await controller.pause();
      }
    } catch (_) {
      if (!_isCurrent(controller, generation)) return;

      // El navegador puede exigir una interacción del usuario para autorizar play().
      if (mounted) {
        setState(() => _wantsToPlay = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  Widget _failure(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 70, 82, 160),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 46),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_supported)
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _wantsToPlay = true;
                    });
                    _initialize();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
    }

    if (_error != null) {
      return _failure(_error!);
    }

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 16),
            Text('Cargando video…'),
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return _failure(
            'El video no se pudo reproducir. Puedes reintentar y comprobar '
            'que la fuente remota entregue un MP4 compatible.',
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _wantsToPlay = !value.isPlaying;
            unawaited(_synchronize());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              if (!value.isPlaying && !value.isBuffering)
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 78,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              if (value.isBuffering)
                const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: false,
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    bufferedColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
