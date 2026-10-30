import 'package:flutter/material.dart';

/// Acentos disponibles para personalizar la interfaz oscura.
const colorList = <Color>[
  Color(0xFFFFB000), // Ámbar eléctrico
  Color(0xFF00D5C4), // Turquesa neón
  Color(0xFF7CFF6B), // Lima
  Color(0xFFFF5C7A), // Coral
  Color(0xFF9D7BFF), // Violeta
  Color(0xFF62B6FF), // Azul hielo
  Color(0xFFFF7A30), // Naranja
  Color(0xFFFF63D8), // Fucsia
  Color(0xFFC7D2E0), // Plata
];

const colorNameList = <String>[
  'Ámbar eléctrico',
  'Turquesa neón',
  'Verde lima',
  'Coral brillante',
  'Violeta espacial',
  'Azul hielo',
  'Naranja solar',
  'Fucsia digital',
  'Plata lunar',
];

class AppTheme {
  final int selectedColor;
  final bool isDarkmode;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = true,
  })  : assert(selectedColor >= 0, 'El índice de color no puede ser negativo'),
        assert(selectedColor < colorList.length,
            'El índice de color supera la paleta disponible');

  ThemeData getTheme() {
    final brightness = isDarkmode ? Brightness.dark : Brightness.light;
    final seed = colorList[selectedColor];
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final scheme = generatedScheme.copyWith(
      surface: isDarkmode ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDarkmode ? const Color(0xFF050505) : const Color(0xFFF3F4F6),
      canvasColor: isDarkmode ? const Color(0xFF0B0B0B) : Colors.white,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor:
            isDarkmode ? const Color(0xFF090909) : scheme.primaryContainer,
        foregroundColor:
            isDarkmode ? Colors.white : scheme.onPrimaryContainer,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor:
            isDarkmode ? const Color(0xFF101010) : const Color(0xFFFFFFFF),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDarkmode ? const Color(0xFF242424) : const Color(0xFF252525),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDarkmode ? const Color(0xFF151515) : const Color(0xFFFFFFFF),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  AppTheme copyWith({int? selectedColor, bool? isDarkmode}) => AppTheme(
        selectedColor: selectedColor ?? this.selectedColor,
        isDarkmode: isDarkmode ?? this.isDarkmode,
      );
}
