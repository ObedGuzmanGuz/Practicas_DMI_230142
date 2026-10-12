import 'package:flutter/material.dart';

/// Implementación vacía para plataformas que no son Flutter Web.
/// En Android/iOS se usa el reproductor integrado de embedded_platform_player.dart.
class WebEmbeddedPlatformPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) => const ColoredBox(color: Colors.black);
}
