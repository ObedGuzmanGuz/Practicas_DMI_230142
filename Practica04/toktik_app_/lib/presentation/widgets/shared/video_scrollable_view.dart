import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/expandable_caption.dart';
import 'package:toktik_app/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik_app/presentation/widgets/video/embedded_platform_player.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik_app/presentation/widgets/video/video_background.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  final bool feedActive;

  const VideoScrollableView({
    super.key,
    required this.videos,
    this.feedActive = true,
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  final _pageController = PageController();
  final _activePage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _activePage.dispose();
    super.dispose();
  }

  void _move(int offset) {
    if (widget.videos.isEmpty) return;
    final target = (_activePage.value + offset)
        .clamp(0, widget.videos.length - 1)
        .toInt();
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) return const SizedBox.shrink();

    final provider = context.watch<DiscoverProvider>();
    final colors = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        _activePage.value = index;
        if (widget.feedActive && index >= widget.videos.length - 3) {
          provider.loadMoreVideos();
        }
      },
      itemBuilder: (context, index) {
        final video = widget.videos[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _activePage,
              builder: (context, activeIndex, _) {
                final active = widget.feedActive && index == activeIndex;
                if (video.usesEmbeddedPlayer) {
                  final uri = Uri.parse(video.videoUrl);
                  final muteKey = video.source == 'Vimeo' ? 'muted' : 'mute';
                  final muteValue = video.source == 'Dailymotion'
                      ? (provider.muted ? 'true' : 'false')
                      : (provider.muted ? '1' : '0');
                  final embedUrl = uri.replace(queryParameters: {
                    ...uri.queryParameters,
                    muteKey: muteValue,
                  }).toString();
                  return EmbeddedPlatformPlayer(
                    key: ValueKey(video.driveFileId),
                    embedUrl: embedUrl,
                    active: active,
                    isYouTube: video.source == 'YouTube',
                    muted: provider.muted,
                    onView: () => provider.registerView(video.number),
                  );
                }
                return FullScreenPlayer(
                  key: ValueKey(video.driveFileId),
                  videoUrl: video.videoUrl,
                  driveFileId: video.driveFileId,
                  active: active,
                  muted: provider.muted,
                  onPlaybackStarted: () => provider.registerView(video.number),
                );
              },
            ),
            const VideoBackground(),
            Positioned(
              top: 90,
              right: 16,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: background.withValues(alpha: .42),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: .10)),
                  ),
                  child: Text(
                    '${index + 1}/${widget.videos.length}',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 90,
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PRÁCTICA 04  /  ${video.source.toUpperCase()}',
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ExpandableCaption(text: video.description),
                    const SizedBox(height: 8),
                    Text(
                      'Desliza para explorar · Toca para pausar/reanudar',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: .68),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Video anterior',
                          onPressed: index == 0 ? null : () => _move(-1),
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        IconButton(
                          tooltip: 'Video siguiente',
                          onPressed: index == widget.videos.length - 1 ? null : () => _move(1),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (video.source == 'Coverr')
              Positioned(
                top: 126,
                left: 16,
                child: SafeArea(
                  child: InkWell(
                    onTap: () => launchUrl(Uri.parse('https://coverr.co/')),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Video por Coverr · Ver fuente',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 45,
              right: 16,
              child: SafeArea(
                top: false,
                child: VideoButtons(video: video),
              ),
            ),
          ],
        );
      },
    );
  }
}
