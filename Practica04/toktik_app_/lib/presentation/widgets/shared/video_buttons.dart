import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/helpers/human_formats.dart';
import 'package:toktik_app/config/theme/app_theme.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';

class VideoButtons extends StatelessWidget {
  final VideoPost video;
  const VideoButtons({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: video.isLiked ? 'Quitar me gusta' : 'Me gusta',
          onPressed: () => provider.toggleLike(video.number),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              video.isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(video.isLiked),
              size: 32,
              color: AppTheme.accent,
            ),
          ),
        ),
        Text(HumanFormats.humanReadableNumber(video.likes)),
        const SizedBox(height: 18),
        Tooltip(
          message: 'Reproducciones en esta sesión',
          child: const Icon(Icons.visibility_outlined, size: 30),
        ),
        Text(HumanFormats.humanReadableNumber(video.views)),
        const SizedBox(height: 18),
        IconButton(
          tooltip: provider.muted ? 'Activar sonido' : 'Silenciar',
          onPressed: provider.toggleMuted,
          icon: Icon(
            provider.muted ? Icons.volume_off : Icons.volume_up,
            color: AppTheme.accent,
            size: 30,
          ),
        ),
      ],
    );
  }
}
