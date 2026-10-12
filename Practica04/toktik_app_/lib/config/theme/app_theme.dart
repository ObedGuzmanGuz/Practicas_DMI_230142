import 'package:flutter/material.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';

class AppTheme {
  static const background = Color(0xFF071020);
  static const surface = Color(0xFF0C1629);
  static const accent = Color(0xFF00B4FF);
  static const accentSecondary = Color(0xFF7C4DFF);
  static const pink = Color(0xFFFF2D95);
  static const text = Color(0xFFF4F7FF);
  static const secondaryText = Color(0xFFA8B3C7);
  static const divider = Color(0xFF1A2940);

  static const brandGradient = LinearGradient(
    colors: [accent, accentSecondary, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  ThemeData getTheme() => getSeasonalTheme(AppSeason.normal);

  ThemeData getSeasonalTheme(AppSeason season) {
    final palette = SeasonalPalette.forSeason(season);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: palette.fontFamily,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        onPrimary: palette.background,
        secondary: palette.secondary,
        onSecondary: palette.text,
        tertiary: palette.tertiary,
        surface: palette.surface,
        onSurface: palette.text,
        outline: palette.divider,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: palette.fontFamily,
        bodyColor: palette.text,
        displayColor: palette.text,
      ),
      iconTheme: IconThemeData(color: palette.text),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background.withValues(alpha: .88),
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: false,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
