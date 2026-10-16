import 'package:flutter/material.dart';

/// Temporadas visuales admitidas por TokTik Azul.
enum AppSeason { normal, halloween, christmas, valentinesDay }

/// Opción que el usuario elige en el selector. Automatic usa el calendario.
enum SeasonMode { automatic, normal, halloween, christmas, valentinesDay }

extension AppSeasonLabel on AppSeason {
  String get label => switch (this) {
        AppSeason.normal => 'Normal',
        AppSeason.halloween => 'Halloween',
        AppSeason.christmas => 'Navidad',
        AppSeason.valentinesDay => "Valentine's Day",
      };

  IconData get icon => switch (this) {
        AppSeason.normal => Icons.auto_awesome,
        AppSeason.halloween => Icons.nightlight_round,
        AppSeason.christmas => Icons.ac_unit,
        AppSeason.valentinesDay => Icons.favorite,
      };

  String get audioAsset => switch (this) {
        AppSeason.normal => 'audio/normal.wav',
        AppSeason.halloween => 'audio/halloween.wav',
        AppSeason.christmas => 'audio/christmas.wav',
        AppSeason.valentinesDay => 'audio/valentines.wav',
      };

}


AppSeason seasonForDate(DateTime date) {
  // Halloween está activo del 28 de octubre al 2 de noviembre.
  if ((date.month == DateTime.october && date.day >= 28) ||
      (date.month == DateTime.november && date.day <= 2)) {
    return AppSeason.halloween;
  }
  if (date.month == DateTime.december) return AppSeason.christmas;
  if (date.month == DateTime.february && date.day <= 14) {
    return AppSeason.valentinesDay;
  }
  return AppSeason.normal;
}

class SeasonalPalette {
  const SeasonalPalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.text,
    required this.secondaryText,
    required this.divider,
    required this.fontFamily,
  });

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color text;
  final Color secondaryText;
  final Color divider;
  final String fontFamily;

  static SeasonalPalette forSeason(AppSeason season) => switch (season) {
        AppSeason.normal => const SeasonalPalette(
            background: Color(0xFF071020),
            surface: Color(0xFF0C1629),
            primary: Color(0xFF00B4FF),
            secondary: Color(0xFF7C4DFF),
            tertiary: Color(0xFFFF2D95),
            text: Color(0xFFF4F7FF),
            secondaryText: Color(0xFFA8B3C7),
            divider: Color(0xFF1A2940),
            fontFamily: 'sans-serif',
          ),
        AppSeason.halloween => const SeasonalPalette(
            background: Color(0xFF140B1D),
            surface: Color(0xFF21112D),
            primary: Color(0xFFFF9F1C),
            secondary: Color(0xFF9D4EDD),
            tertiary: Color(0xFFE63946),
            text: Color(0xFFFFF7ED),
            secondaryText: Color(0xFFD0B9D9),
            divider: Color(0xFF40234E),
            fontFamily: 'serif',
          ),
        AppSeason.christmas => const SeasonalPalette(
            background: Color(0xFF071C18),
            surface: Color(0xFF0F2A22),
            primary: Color(0xFF42E695),
            secondary: Color(0xFFE84A5F),
            tertiary: Color(0xFFF5C451),
            text: Color(0xFFF4FFF8),
            secondaryText: Color(0xFFB5D0C6),
            divider: Color(0xFF1E493A),
            fontFamily: 'sans-serif-condensed',
          ),
        AppSeason.valentinesDay => const SeasonalPalette(
            background: Color(0xFF260E1C),
            surface: Color(0xFF351329),
            primary: Color(0xFFFF75A0),
            secondary: Color(0xFFE84B7D),
            tertiary: Color(0xFFFFC857),
            text: Color(0xFFFFF2F7),
            secondaryText: Color(0xFFE2B8C9),
            divider: Color(0xFF51213B),
            fontFamily: 'serif',
          ),
        };
}
