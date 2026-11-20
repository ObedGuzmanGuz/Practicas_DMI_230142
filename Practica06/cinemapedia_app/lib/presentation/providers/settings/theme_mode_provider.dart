import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  bool _userChangedTheme = false;

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final preferences = SharedPreferencesAsync();
      final storedMode = await preferences.getString('cinemapedia_theme_mode');
      if (!mounted || _userChangedTheme) return;
      state = storedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    } catch (_) {
      // Si el dispositivo no permite guardar preferencias, se mantiene el tema oscuro.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _userChangedTheme = true;
    state = mode;
    try {
      final preferences = SharedPreferencesAsync();
      await preferences.setString(
        'cinemapedia_theme_mode',
        mode == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {
      // El cambio visual se conserva aunque no se pueda guardar la preferencia.
    }
  }

  Future<void> toggle() => setThemeMode(
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );
}
