import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullScreenLoader extends ConsumerWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(region);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(strings.pleaseWait),
          const SizedBox(height: 12),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 12),
          Text(strings.loadingMovies),
        ],
      ),
    );
  }
}
