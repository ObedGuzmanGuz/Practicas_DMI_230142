import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF071426);
  static const accent = Color(0xFF42B9FF);
  static const text = Color(0xFFD0EBFF);
  static const secondaryText = Color(0xFF93C5FD);

  ThemeData getTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        primary: accent,
        onPrimary: background,
        surface: background,
        onSurface: text,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      iconTheme: const IconThemeData(color: accent),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: accent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
    );
  }
}
