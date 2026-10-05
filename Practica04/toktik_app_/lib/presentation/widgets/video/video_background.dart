import 'package:flutter/material.dart';
import 'package:toktik_app/config/theme/app_theme.dart';

class VideoBackground extends StatelessWidget {
  const VideoBackground({super.key});
  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x99071426),
              Colors.transparent,
              AppTheme.background,
            ],
            stops: [0, 0.45, 1],
          ),
        ),
      ),
    ),
  );
}
