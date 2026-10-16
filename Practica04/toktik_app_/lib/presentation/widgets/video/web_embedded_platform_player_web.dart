import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Reproductor embebido para Flutter Web.
/// No depende del puente flutter_inappwebview, que solo existe en plataformas
/// nativas. YouTube se muestra con su iframe oficial y sus eventos de estado.
class WebEmbeddedPlatformPlayer extends StatefulWidget {
  const WebEmbeddedPlatformPlayer({
    super.key,
    required this.embedUrl,
    required this.active,
    required this.onView,
    required this.isYouTube,
    required this.muted,
  });

  final String embedUrl;
  final bool active;
  final VoidCallback onView;
  final bool isYouTube;
  final bool muted;

  @override
  State<WebEmbeddedPlatformPlayer> createState() => _WebEmbeddedPlatformPlayerState();
}

class _WebEmbeddedPlatformPlayerState extends State<WebEmbeddedPlatformPlayer> {
  static int _nextId = 0;

  late final String _viewType;
  late final String _playerId;
  late final JSFunction _messageListener;
  late final JSFunction _loadListener;
  web.HTMLIFrameElement? _iframe;
  Timer? _commandTimer;
  Timer? _controlTimer;
  int _commandAttempts = 0;
  bool _wasPlaying = false;
  bool _isPlaying = false;
  bool _showControl = true;
  bool _viewReported = false;
  String? _youtubeErrorCode;

  @override
  void initState() {
    super.initState();
    final id = _nextId++;
    _viewType = 'toktik-embedded-video-$id';
    _playerId = 'toktik_player_$id';
    _messageListener = ((web.Event event) {
      if (event is! web.MessageEvent) return;
      final frame = _iframe;
      if (frame == null || event.source != frame.contentWindow) return;
      final rawData = event.data;
      if (rawData is! JSString) return;

      try {
        final payload = jsonDecode(rawData.toDart);
        if (payload is! Map<String, dynamic>) return;
        if (payload['event'] == 'onError') {
          final code = payload['info']?.toString() ?? 'desconocido';
          if (mounted) setState(() => _youtubeErrorCode = code);
          debugPrint('YouTube IFrame Player API error en web: $code');
          return;
        }

        // Solo usamos onStateChange; infoDelivery puede repetirse durante la reproducción
        // y no debe reiniciar el temporizador del control de pausa en cada actualización.
        if (payload['event'] != 'onStateChange' || payload['info'] is! int) return;
        final state = payload['info'] as int;

        // El estado 1 significa PLAYING. Cuenta cada transición real a reproducción,
        // incluyendo cuando el usuario pausa y vuelve a reproducir el mismo video.
        if (state == 1 && !_wasPlaying) {
          widget.onView();
          _wasPlaying = true;
        } else if (state != 1) {
          _wasPlaying = false;
        }
        if (widget.isYouTube && mounted) {
          _controlTimer?.cancel();
          if (state == 1) {
            setState(() {
              _isPlaying = true;
              _showControl = true;
            });
            _controlTimer = Timer(const Duration(milliseconds: 850), () {
              if (mounted && _isPlaying) setState(() => _showControl = false);
            });
          } else if (state == 2 || state == 0 || state == 5) {
            setState(() {
              _isPlaying = false;
              _showControl = true;
            });
          }
        }
      } catch (_) {
        // Otros mensajes del iframe no son eventos de estado que nos interesen.
      }
    }).toJS;

    _loadListener = ((web.Event event) {
      if (widget.isYouTube) {
        _youtubeErrorCode = null;
        _commandAttempts = 0;
        _commandTimer?.cancel();
        // El iframe puede tardar unos instantes en quedar listo. Reintenta registrar
        // el evento de reproducción durante unos segundos para evitar perderlo.
        _commandTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
          _sendCommand('addEventListener', <String>['onStateChange']);
          _sendCommand('addEventListener', <String>['onError']);
          _announceListening();
          _commandAttempts++;
          if (_commandAttempts >= 12) timer.cancel();
        });
      } else if (!_viewReported) {
        // Vimeo/Dailymotion no exponen el mismo puente de eventos en esta vista web;
        // registra una vista al cargar el reproductor como comportamiento de respaldo.
        _viewReported = true;
        widget.onView();
      }
    }).toJS;

    web.window.addEventListener('message', _messageListener);
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement();
      iframe.src = _makeEmbedUrl();
      iframe.title = widget.isYouTube ? 'Reproductor oficial de YouTube' : 'Reproductor de video';
      iframe.allow = 'autoplay; encrypted-media; picture-in-picture; web-share';
      iframe.allowFullscreen = true;
      iframe.referrerPolicy = 'strict-origin-when-cross-origin';
      iframe.style
        ..border = '0'
        ..width = '100%'
        ..height = '100%'
        ..backgroundColor = '#000000';
      iframe.addEventListener('load', _loadListener);
      _iframe = iframe;
      return iframe;
    });
  }

  String _makeEmbedUrl() {
    final uri = Uri.tryParse(widget.embedUrl);
    if (uri == null || !uri.hasAuthority) return widget.embedUrl;
    if (!widget.isYouTube) return widget.embedUrl;

    final path = uri.pathSegments;
    final videoId = path.isEmpty ? '' : path.last;
    final query = <String, String>{
      ...uri.queryParameters,
      'autoplay': '1',
      'controls': '0',
      'fs': '0',
      'disablekb': '1',
      'iv_load_policy': '3',
      'playsinline': '1',
      'rel': '0',
      'enablejsapi': '1',
      'mute': widget.muted ? '1' : '0',
      'origin': web.window.location.origin,
      'widget_referrer': web.window.location.href,
      'widgetid': _playerId,
    };
    return Uri.https('www.youtube.com', '/embed/$videoId', query).toString();
  }

  void _announceListening() {
    _iframe?.contentWindow?.postMessage(
      jsonEncode(<String, Object>{
        'event': 'listening',
        'id': _playerId,
        'channel': 'widget',
      }).toJS,
      '*'.toJS,
    );
  }

  void _sendCommand(String command, [List<String> args = const <String>[]]) {
    _iframe?.contentWindow?.postMessage(
      jsonEncode(<String, Object>{
        'event': 'command',
        'func': command,
        'args': args,
        'id': _playerId,
        'channel': 'widget',
      }).toJS,
      '*'.toJS,
    );
  }

  void _togglePlayback() {
    if (!widget.isYouTube || _youtubeErrorCode != null) return;
    _controlTimer?.cancel();
    setState(() => _showControl = true);
    _sendCommand(_isPlaying ? 'pauseVideo' : 'playVideo');
  }

  @override
  void didUpdateWidget(covariant WebEmbeddedPlatformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muted != widget.muted && widget.isYouTube) {
      _sendCommand(widget.muted ? 'mute' : 'unMute');
    }
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HtmlElementView(viewType: _viewType),
            if (widget.isYouTube)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _togglePlayback,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _showControl ? 1 : 0,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .52),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1.4),
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_youtubeErrorCode != null)
              ColoredBox(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.videocam_off, color: Colors.white, size: 42),
                        const SizedBox(height: 12),
                        const Text(
                          'Este Short no se puede reproducir aquí. Puede tener las inserciones bloqueadas o haber sido eliminado.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Código de YouTube: $_youtubeErrorCode',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Desliza al siguiente video.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  @override
  void dispose() {
    _commandTimer?.cancel();
    _controlTimer?.cancel();
    _iframe?.removeEventListener('load', _loadListener);
    web.window.removeEventListener('message', _messageListener);
    _iframe = null;
    super.dispose();
  }
}
