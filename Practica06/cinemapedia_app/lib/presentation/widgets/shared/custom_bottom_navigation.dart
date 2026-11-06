import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(ref.watch(selectedMovieRegionProvider));

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/categories');
            break;
          case 2:
            context.go('/favorites');
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.movie_outlined),
          selectedIcon: const Icon(Icons.movie_rounded),
          label: strings.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_rounded),
          selectedIcon: const Icon(Icons.apps_rounded),
          label: strings.categories,
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_border_rounded),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: strings.favorites,
        ),
      ],
    );
  }
}
