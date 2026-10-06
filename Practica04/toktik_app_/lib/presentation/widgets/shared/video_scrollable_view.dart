import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/theme/app_theme.dart';
import 'package:toktik_app/domain/entities/video_post.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik_app/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik_app/presentation/widgets/video/video_background.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;
  const VideoScrollableView({super.key, required this.videos});
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
    final target = (_activePage.value + offset).clamp(
      0,
      widget.videos.length - 1,
    );
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const Center(child: Text('No hay videos disponibles.'));
    }
    final provider = context.watch<DiscoverProvider>();
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      onPageChanged: (index) => _activePage.value = index,
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _activePage,
              builder: (context, activeIndex, _) => FullScreenPlayer(
                key: ValueKey(video.driveFileId),
                videoUrl: video.videoUrl,
                driveFileId: video.driveFileId,
                active: index == activeIndex,
                muted: provider.muted,
                onFirstPlay: () => provider.registerView(video.number),
              ),
            ),
            const VideoBackground(),
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'TOKTIK ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 17, 18, 19),
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Text(
                        '${index + 1} / ${widget.videos.length}',
                        style: const TextStyle(color: AppTheme.secondaryText),
                      ),
                    ],
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
                    const Text(
                      'PRÁCTICA 04  ',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Desliza para explorar · Toca para pausar',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
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
                          onPressed: index == widget.videos.length - 1
                              ? null
                              : () => _move(1),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 45,
              right: 16,
              child: SafeArea(top: false, child: VideoButtons(video: video)),
            ),
          ],
        );
      },
    );
  }
}
