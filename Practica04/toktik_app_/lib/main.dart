import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/theme/app_theme.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/providers/seasonal_theme_provider.dart';
import 'package:toktik_app/presentation/screens/splash/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = SeasonalThemeProvider();
            unawaited(provider.initialize());
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => DiscoverProvider()..loadNextPage(),
        ),
      ],
      child: Consumer<SeasonalThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'TokTik Azul',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().getSeasonalTheme(themeProvider.season),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
