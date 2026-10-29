import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavigation extends ConsumerWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(selectedMovieRegionProvider);
    final isEnglish = region.isoCode == 'US';
    final isJapanese = region.isoCode == 'JP';
    final isGerman = region.isoCode == 'DE';

    return BottomNavigationBar(
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_max),
          label: isEnglish ? 'Home' : isJapanese ? 'ホーム' : isGerman ? 'Start' : 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.label_outline),
          label: isEnglish ? 'Categories' : isJapanese ? 'カテゴリー' : isGerman ? 'Kategorien' : 'Categorías',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          label: isEnglish ? 'Favorites' : isJapanese ? 'お気に入り' : isGerman ? 'Favoriten' : 'Favoritos',
        ),
      ],
    );
  }
}
