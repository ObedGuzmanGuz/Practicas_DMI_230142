import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_webview_flutter/flutter_inappwebview.dart';
import 'web_embedded_platform_player_stub.dart'
    if (dart.library.html) 'web_embedded_platform_player_web.dart';

/// Reproduce páginas de inserción oficiales. Para YouTube usa IFrame Player API
/// para detectar cada inicio real de reproducción y registrar una vista.
class EmbeddedPlatformPlayer extends StatefulWidget {
  const EmbeddedPlatformPlayer({
    super.key,
    required this.embedUrl,
    required this.active,
    required this.onView,
    this.isYouTube = false,
    this.muted = true,
  });

  final String embedUrl;
  final bool active;
  final VoidCallback onView;
  final bool isYouTube;
  final bool muted;

  @override
  State<EmbeddedPlatformPlayer> createState() => _EmbeddedPlatformPlayerState();
}

class _EmbeddedPlatformPlayerState extends State<EmbeddedPlatformPlayer>
    with WidgetsBindingObserver {
  InAppWebViewController? _controller;
  bool _loading = true;
  bool _viewReported = false;
  bool _foreground = true;
  bool _youtubeIsPlaying = false;
  bool _showYoutubeControl = true;
  bool _resumeAfterLifecycle = false;
  Timer? _youtubeControlTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didUpdateWidget(covariant EmbeddedPlatformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _controller = null;
      return;
    }

    if (widget.isYouTube && oldWidget.muted != widget.muted) {
      final controller = _controller;
      if (controller != null) {
        unawaited(controller.evaluateJavascript(
          source: 'if (typeof setYouTubeMuted === "function") setYouTubeMuted(${widget.muted});',
        ).then<void>((_) {}).catchError((Object error) {
          debugPrint('No se pudo cambiar el audio de YouTube: $error');
        }));
      }
    } else if (!widget.isYouTube && oldWidget.embedUrl != widget.embedUrl) {
      _loading = true;
      _errorMessage = null;
      final controller = _controller;
      if (mounted) setState(() {});
      if (controller != null) {
        unawaited(controller
            .loadUrl(urlRequest: URLRequest(url: WebUri(widget.embedUrl)))
            .catchError((Object error) {
          debugPrint('No se pudo actualizar el reproductor embebido: $error');
        }));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (!resumed && widget.isYouTube && _youtubeIsPlaying) {
      _resumeAfterLifecycle = true;
      _runYouTubeCommand('pauseYouTubePlayback();');
    }
    _foreground = resumed;
    if (resumed && _resumeAfterLifecycle && widget.isYouTube && widget.active) {
      _resumeAfterLifecycle = false;
      // Mantiene la posición actual del video: no se recrea el WebView al volver a la app.
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (mounted && widget.active && _foreground) {
          _runYouTubeCommand('playYouTubePlayback();');
        }
      });
    }
    if (mounted) setState(() {});
  }

  void _onYouTubeState(int state) {
    if (!mounted) return;
    _youtubeControlTimer?.cancel();
    if (state == 1) {
      setState(() {
        _youtubeIsPlaying = true;
        _showYoutubeControl = true;
      });
      _youtubeControlTimer = Timer(const Duration(milliseconds: 850), () {
        if (mounted && _youtubeIsPlaying) {
          setState(() => _showYoutubeControl = false);
        }
      });
    } else if (state == 2 || state == 0 || state == 5) {
      setState(() {
        _youtubeIsPlaying = false;
        _showYoutubeControl = true;
      });
    }
  }

  void _runYouTubeCommand(String command) {
    final controller = _controller;
    if (controller == null) return;
    unawaited(controller.evaluateJavascript(source: command).then<void>((_) {}).catchError((Object error) {
      debugPrint('No se pudo controlar el video de YouTube: $error');
    }));
  }

  void _toggleYouTubePlayback() {
    if (_loading || _errorMessage != null) return;
    _youtubeControlTimer?.cancel();
    setState(() => _showYoutubeControl = true);
    _runYouTubeCommand('toggleYouTubePlayback();');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      _controller = null;
      return const ColoredBox(color: Colors.black);
    }

    // Flutter Web no ofrece el puente JavaScript de in_app_webview_flutter.
    // En el navegador se usa un iframe HTML oficial; Android/iOS conservan WebView.
    if (kIsWeb) {
      return WebEmbeddedPlatformPlayer(
        embedUrl: widget.embedUrl,
        active: widget.active,
        onView: widget.onView,
        isYouTube: widget.isYouTube,
        muted: widget.muted,
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InAppWebView(
            key: ValueKey(widget.isYouTube ? 'youtube-iframe-player' : 'social-platform-webview'),
            initialData: widget.isYouTube
                ? InAppWebViewInitialData(
                    data: _youtubePlayerHtml(),
                    // YouTube exige un Referer con un origen HTTPS sintácticamente válido.
                    // El host usa un dominio reservado de ejemplo para que WebView genere
                    // la cabecera Referer en lugar de un host con guiones bajos.
                    baseUrl: WebUri('https://com.example.toktikapp.example/'),
                  )
                : null,
            initialUrlRequest: widget.isYouTube
                ? null
                : URLRequest(url: WebUri(widget.embedUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              supportZoom: false,
              disableHorizontalScroll: true,
              disableVerticalScroll: true,
              transparentBackground: false,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
              if (widget.isYouTube) {
                controller.addJavaScriptHandler(
                  handlerName: 'youtubePlaybackStarted',
                  callback: (args) {
                    if (mounted && widget.active && _foreground) {
                      widget.onView();
                    }
                    return null;
                  },
                );
                controller.addJavaScriptHandler(
                  handlerName: 'youtubePlayerState',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      final state = int.tryParse(args.first.toString());
                      if (state != null) _onYouTubeState(state);
                    }
                    return null;
                  },
                );
                controller.addJavaScriptHandler(
                  handlerName: 'youtubePlayerError',
                  callback: (args) {
                    final code = args.isNotEmpty ? args.first.toString() : 'desconocido';
                    debugPrint('YouTube IFrame Player API error: $code. El video puede bloquear inserciones o no estar disponible.');
                    if (mounted) {
                      final message = switch (code) {
                        '100' => 'Este video ya no está disponible en YouTube. Desliza al siguiente Short.',
                        '101' || '150' => 'El propietario restringió la reproducción de este video fuera de YouTube. Desliza al siguiente Short.',
                        '153' => 'YouTube no recibió la identificación de la app. Reintenta la reproducción o desliza al siguiente Short.',
                        _ => 'No se pudo reproducir este video de YouTube (error $code). Desliza al siguiente Short.',
                      };
                      setState(() {
                        _loading = false;
                        _errorMessage = message;
                      });
                    }
                    return null;
                  },
                );
              }
            },
            onLoadStart: (controller, url) {
              if (mounted) {
                setState(() {
                  _loading = true;
                  _errorMessage = null;
                });
              }
            },
            onLoadStop: (controller, url) {
              if (!mounted) return;
              setState(() => _loading = false);
              // YouTube reporta cada reproducción desde su evento PLAYING.
              // Las otras plataformas usan una vista por carga como respaldo.
              if (!widget.isYouTube && !_viewReported) {
                _viewReported = true;
                widget.onView();
              }
            },
            onReceivedError: (controller, request, error) {
              debugPrint('Error WebView (${request.url}): ${error.description}');
              if (!mounted || request.isForMainFrame == false) return;
              setState(() {
                _loading = false;
                _errorMessage = 'No se pudo cargar este video. Comprueba tu conexión o si el proveedor permite insertarlo.';
              });
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              debugPrint('HTTP ${errorResponse.statusCode} al cargar ${request.url}');
              if (!mounted || request.isForMainFrame == false) return;
              if ((errorResponse.statusCode ?? 0) < 400) return;
              setState(() {
                _loading = false;
                _errorMessage = 'El proveedor rechazó la reproducción (HTTP ${errorResponse.statusCode ?? 'desconocido'}).';
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('WebView ${widget.embedUrl}: ${consoleMessage.message}');
            },
          ),
          if (widget.isYouTube)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleYouTubePlayback,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _showYoutubeControl ? 1 : 0,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .52),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: .7), width: 1.4),
                        ),
                        child: Icon(
                          _youtubeIsPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!_foreground)
            const Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Colors.black)),
            ),
          if (_loading)
            const IgnorePointer(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_errorMessage != null)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.white, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _youtubePlayerHtml() {
    final uri = Uri.tryParse(widget.embedUrl);
    final id = uri == null || uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final safeId = RegExp(r'^[A-Za-z0-9_-]{6,20}$').hasMatch(id) ? id : '';
    final startMuted = widget.muted ? 'true' : 'false';
    return '''<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta name="referrer" content="strict-origin-when-cross-origin">
<style>html,body,#player{margin:0;padding:0;width:100%;height:100%;background:#000;overflow:hidden}body{font-family:Arial,sans-serif}</style>
</head>
<body>
<div id="player"></div>
<script>
var toktikPlayer;
var initialMuted = $startMuted;
var wasPlaying = false;
function setYouTubeMuted(muted) {
  initialMuted = !!muted;
  if (!toktikPlayer || !toktikPlayer.isReady) return;
  try { if (initialMuted) toktikPlayer.mute(); else toktikPlayer.unMute(); } catch (e) {}
}
function playYouTubePlayback() {
  if (toktikPlayer && toktikPlayer.isReady) { try { toktikPlayer.playVideo(); } catch (e) {} }
}
function pauseYouTubePlayback() {
  if (toktikPlayer && toktikPlayer.isReady) { try { toktikPlayer.pauseVideo(); } catch (e) {} }
}
function toggleYouTubePlayback() {
  if (!toktikPlayer || !toktikPlayer.isReady) return;
  try {
    var state = toktikPlayer.getPlayerState();
    if (state === YT.PlayerState.PLAYING || state === YT.PlayerState.BUFFERING) toktikPlayer.pauseVideo();
    else toktikPlayer.playVideo();
  } catch (e) {}
}
function onYouTubeIframeAPIReady() {
  toktikPlayer = new YT.Player('player', {
    width: '100%', height: '100%', videoId: '$safeId',
    playerVars: {
      autoplay: 1, controls: 0, playsinline: 1, rel: 0, fs: 0, disablekb: 1,
      iv_load_policy: 3, enablejsapi: 1, origin: 'https://com.example.toktikapp.example',
      widget_referrer: 'https://com.example.toktikapp.example/'
    },
    events: {
      onReady: function(event) {
        toktikPlayer.isReady = true;
        if (initialMuted) event.target.mute(); else event.target.unMute();
        event.target.playVideo();
      },
      onStateChange: function(event) {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('youtubePlayerState', event.data);
        }
        if (event.data === YT.PlayerState.PLAYING && !wasPlaying) {
          wasPlaying = true;
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('youtubePlaybackStarted');
          }
        } else if (event.data !== YT.PlayerState.PLAYING) {
          wasPlaying = false;
        }
      },
      onError: function(event) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('youtubePlayerError', event.data);
        }
      }
    }
  });
}
var apiTag = document.createElement('script');
apiTag.src = 'https://www.youtube.com/iframe_api';
var firstScript = document.getElementsByTagName('script')[0];
firstScript.parentNode.insertBefore(apiTag, firstScript);
</script>
</body>
</html>''';
  }

  Future<void> _retry() async {
    final controller = _controller;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _viewReported = false;
    });
    try {
      if (controller != null) {
        if (widget.isYouTube) {
          await controller.reload();
        } else {
          await controller.reload();
        }
      } else {
        setState(() {
          _loading = false;
          _errorMessage = 'El reproductor todavía no está listo. Desliza a otro video y regresa.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo reintentar la reproducción: $error';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _youtubeControlTimer?.cancel();
    _controller = null;
    super.dispose();
  }
}
