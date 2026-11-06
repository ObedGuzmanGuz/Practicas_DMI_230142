import 'package:cinemapedia_app/config/router/app_router.dart';
import 'package:cinemapedia_app/config/theme/app_theme.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedMovieRegionProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Cinemapedia',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().lightTheme,
      darkTheme: AppTheme().darkTheme,
      themeMode: themeMode,
      locale: selectedRegion.locale,
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('de', 'DE'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
