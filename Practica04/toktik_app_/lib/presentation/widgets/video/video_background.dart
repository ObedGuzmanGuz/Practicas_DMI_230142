import 'package:flutter/material.dart';

class VideoBackground extends StatelessWidget {
  const VideoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor.withValues(alpha: .66),
                Colors.transparent,
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0, .45, 1],
            ),
          ),
        ),
      ),
    );
  }
}
