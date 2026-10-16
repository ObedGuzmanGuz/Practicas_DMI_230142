import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/providers/seasonal_theme_provider.dart';
import 'package:toktik_app/presentation/screens/discover/discover_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    unawaited(_openApp());
  }

  Future<void> _openApp() async {
    final provider = context.read<DiscoverProvider>();
    final seasonalProvider = context.read<SeasonalThemeProvider>();

    // Espera a leer la preferencia estacional y arrancar la melodía inicial.
    while (!seasonalProvider.initialized && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }

    // La melodía dura 5 segundos; el splash no desaparece antes de que termine.
    final minimumSplash = Future<void>.delayed(const Duration(seconds: 5));
    while (provider.initialLoading && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }

    await minimumSplash;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const DiscoverScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final seasonal = context.watch<SeasonalThemeProvider>();
    final season = seasonal.season;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.15,
            colors: [colors.secondary.withValues(alpha: .18), background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 138,
                      height: 138,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: .62),
                        ),
                        gradient: LinearGradient(
                          colors: [background, colors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: .16),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: colors.secondary.withValues(alpha: .11),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/brand/toktik_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: -5,
                            bottom: -5,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.primary, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(alpha: .35),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Icon(season.icon, color: colors.primary, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(colors: [colors.primary, colors.secondary, colors.tertiary]).createShader(bounds),
                    child: const Text(
                      'TOKTIK AZUL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    season.label.toUpperCase(),
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'DESCUBRE · DISFRUTA · COMPARTE',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: .68),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cargando videos…',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: .68),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
