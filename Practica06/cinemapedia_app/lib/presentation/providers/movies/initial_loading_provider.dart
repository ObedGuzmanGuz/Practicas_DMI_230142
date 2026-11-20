import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'movies_providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  ref.watch(nowPlayingMoviesProvider);
  ref.watch(popularMoviesProvider);
  ref.watch(topRatedMoviesProvider);
  ref.watch(upcomingMoviesProvider);

  final notifiers = [
    ref.read(nowPlayingMoviesProvider.notifier),
    ref.read(popularMoviesProvider.notifier),
    ref.read(topRatedMoviesProvider.notifier),
    ref.read(upcomingMoviesProvider.notifier),
  ];
  // La pantalla principal espera a que terminen las cuatro consultas iniciales.
  return notifiers.any((notifier) => !notifier.hasAttempted);
});
