import 'package:flutter/material.dart';

class AppTheme {
  static const _violet = Color(0xFF7867F7);
  static const _turquoise = Color(0xFF42D7C8);
  static const _coral = Color(0xFFFF78A8);

  ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _violet,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF5948D6),
      secondary: const Color(0xFF008F91),
      tertiary: const Color(0xFFD94F87),
      surface: const Color(0xFFFFFFFF),
      surfaceContainer: const Color(0xFFF0F1FA),
      primaryContainer: const Color(0xFFE8E4FF),
      secondaryContainer: const Color(0xFFD8F7F2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F6FC),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF5F6FC),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF332A75).withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _violet.withValues(alpha: 0.15),
        elevation: 10,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? scheme.primary : const Color(0xFF77798B),
        )),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFFFFF), width: 320),
      chipTheme: ChipThemeData(
        backgroundColor: _violet.withValues(alpha: 0.10),
        selectedColor: _violet.withValues(alpha: 0.19),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEF0F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFF5948D6)),
    );
  }

  ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _violet,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA99DFF),
      secondary: _turquoise,
      tertiary: _coral,
      surface: const Color(0xFF11192B),
      surfaceContainer: const Color(0xFF172239),
      surfaceContainerHighest: const Color(0xFF202D46),
      primaryContainer: const Color(0xFF30275E),
      secondaryContainer: const Color(0xFF153D42),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF090F1D),
      cardColor: const Color(0xFF151F33),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF090F1D),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF151F33),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF101A2D),
        indicatorColor: _violet.withValues(alpha: 0.24),
        elevation: 12,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? const Color(0xFFC6BDFF) : const Color(0xFF9AA6BC),
        )),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF101A2D), width: 320),
      chipTheme: ChipThemeData(
        backgroundColor: _violet.withValues(alpha: 0.17),
        selectedColor: _violet.withValues(alpha: 0.29),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF18243A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xFFA99DFF)),
    );
  }
}
