import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/movies/home_scroll_controller_provider.dart';
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
    final colors = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 72,
      backgroundColor: colors.surface.withValues(alpha: 0.98),
      indicatorColor: colors.primaryContainer,
      elevation: 12,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            if (currentIndex == 0) {
              final controller = ref.read(homeScrollControllerProvider);
              if (controller.hasClients) {
                controller.animateTo(0, duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic);
              }
            } else {
              context.go('/');
            }
            break;
          case 1:
            context.go('/popular');
            break;
          case 2:
            context.go('/categories');
            break;
          case 3:
            context.go('/favorites');
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.movie_filter_outlined),
          selectedIcon: Icon(Icons.movie_filter_rounded, color: colors.primary),
          label: strings.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.local_fire_department_outlined),
          selectedIcon: Icon(Icons.local_fire_department_rounded, color: colors.tertiary),
          label: strings.popular,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded, color: colors.secondary),
          label: strings.categories,
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_outline_rounded),
          selectedIcon: Icon(Icons.favorite_rounded, color: colors.tertiary),
          label: strings.favorites,
        ),
      ],
    );
  }
}
