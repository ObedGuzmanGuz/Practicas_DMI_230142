import 'package:flutter/material.dart';

class AppTheme {
  static const _purple = Color(0xFF8B5CF6);
  static const _deepPurple = Color(0xFF6D28D9);

  ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _deepPurple,
      brightness: Brightness.light,
    ).copyWith(
      primary: _deepPurple,
      secondary: const Color(0xFFB453D8),
      surface: const Color(0xFFFFFCFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F3FA),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF6F3FA),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _purple.withValues(alpha: 0.16),
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFFFFFCFF),
        width: 320,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _purple.withValues(alpha: 0.10),
        selectedColor: _purple.withValues(alpha: 0.20),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _purple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFB794FF),
      secondary: const Color(0xFFE0A5FF),
      surface: const Color(0xFF15121F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0B0912),
      cardColor: const Color(0xFF171321),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF0B0912),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF171321),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF13101B),
        indicatorColor: _purple.withValues(alpha: 0.23),
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF100D18),
        width: 320,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _purple.withValues(alpha: 0.16),
        selectedColor: _purple.withValues(alpha: 0.28),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1625),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
