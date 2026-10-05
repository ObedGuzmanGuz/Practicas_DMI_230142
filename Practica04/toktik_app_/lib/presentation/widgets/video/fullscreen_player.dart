import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik_app/config/helpers/drive_urls.dart';
import 'package:toktik_app/config/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final String driveFileId;
  final bool active;
  final bool muted;
  final VoidCallback onFirstPlay;

  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.driveFileId,
    required this.active,
    required this.muted,
    required this.onFirstPlay,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _loading = false;
  String? _error;
  bool _foreground = true;
  bool _wantsToPlay = true;
  bool _reported = false;
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
    if (widget.active) _initialize();
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

  Future<void> _close(VideoPlayerController controller) async {
    try {
      if (controller.value.isInitialized) await controller.pause();
    } catch (_) {
      // Un fallo de pausa no debe impedir liberar los recursos.
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
    _controller = null;
    if (previous != null) unawaited(_close(previous));
  }

  Future<void> _initialize() async {
    _release();
    _error = null;
    if (!_supported) {
      _loading = false;
      _error =
          'Ejecuta la app en Android, iOS, macOS o Chrome/Edge. '
          'Este reproductor no admite Windows/Linux como aplicación de escritorio.';
      return;
    }
    _loading = true;
    final generation = _generation;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;
    final cancellation = Completer<void>();
    _cancelInitialization = cancellation;
    try {
      await Future.any<void>([controller.initialize(), cancellation.future])
          .timeout(const Duration(seconds: 45));
      if (!_isCurrent(controller, generation)) return;
      await controller.setLooping(true);
      if (!_isCurrent(controller, generation)) return;
      setState(() => _loading = false);
      await _synchronize();
    } catch (_) {
      if (!_isCurrent(controller, generation)) return;
      _release();
      setState(() {
        _loading = false;
        _error =
            'No se pudo cargar el video. Revisa tu conexión, el acceso '
            'público en Drive y la compatibilidad del formato.';
      });
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
        // Si el ciclo de vida cambió durante play(), se pausa de nuevo.
        if (!widget.active || !_foreground || !_wantsToPlay) {
          await controller.pause();
          return;
        }
        if (!_reported && controller.value.isPlaying) {
          _reported = true;
          widget.onFirstPlay();
        }
      } else {
        await controller.pause();
      }
    } catch (_) {
      if (!_isCurrent(controller, generation)) return;
      // El navegador puede exigir un toque para autorizar play().
      setState(() => _wantsToPlay = false);
    }
  }

  Future<void> _openDrive() async {
    _wantsToPlay = false;
    // Iniciar launchUrl directamente conserva el gesto del usuario en web.
    final opening = launchUrl(
      DriveUrls.preview(widget.driveFileId),
      mode: LaunchMode.externalApplication,
    );
    unawaited(_synchronize());
    try {
      if (await opening) return;
    } catch (_) {
      /* Se muestra el mismo aviso si no hay navegador disponible. */
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Drive. Inténtalo otra vez.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  Widget _failure(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 70, 82, 160),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 46),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
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
            TextButton.icon(
              onPressed: _openDrive,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir en Drive'),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const ColoredBox(color: AppTheme.background);
    if (_error != null) return _failure(_error!);
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 16),
            Text('Cargando desde Drive…'),
          ],
        ),
      );
    }
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return _failure(
            'El video no se pudo reproducir. Puedes reintentar '
            'o abrirlo en Drive. Si el formato no es compatible, '
            'consulta la guía para convertirlo a MP4 H.264.',
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
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 78,
                    color: AppTheme.accent,
                  ),
                ),
              if (value.isBuffering)
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: false,
                  colors: const VideoProgressColors(
                    playedColor: AppTheme.accent,
                    bufferedColor: Color(0xFF24628A),
                    backgroundColor: AppTheme.background,
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
