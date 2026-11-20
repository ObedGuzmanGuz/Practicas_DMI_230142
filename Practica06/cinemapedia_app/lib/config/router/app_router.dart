import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia_app/presentation/screens/screens.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/popular',
      name: PopularScreen.name,
      builder: (context, state) => const PopularScreen(),
    ),
    GoRoute(
      path: '/categories',
      name: CategoriesScreen.name,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: FavoritesScreen.name,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/movie/:id',
      name: MovieScreen.name,
      builder: (context, state) {
        final movieId = state.pathParameters['id'] ?? 'no-id';
        return _MovieRoute(movieId: movieId);
      },
    ),
  ],
);


/// Fuerza una ficha independiente al cambiar el ID o el tipo de contenido.
class _MovieRoute extends ConsumerWidget {
  final String movieId;
  const _MovieRoute({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(contentModeProvider);
    return MovieScreen(
      key: ValueKey<String>('${mode.name}-$movieId'),
      movieId: movieId,
    );
  }
}
