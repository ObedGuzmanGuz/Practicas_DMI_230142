import 'package:shared_preferences/shared_preferences.dart';

/// Configuración simple del dispositivo. SharedPreferences conserva el tema
/// mientras la aplicación no se desinstale ni se borren sus datos.
class LocalSettingsStorage {
  static const _seasonModeKey = 'toktik_season_mode';

  Future<String> loadSeasonMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_seasonModeKey) ?? 'automatic';
    } catch (_) {
      return 'automatic';
    }
  }

  Future<void> saveSeasonMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_seasonModeKey, mode);
    } catch (_) {
      // La app sigue funcionando con el tema calculado por fecha.
    }
  }
}
