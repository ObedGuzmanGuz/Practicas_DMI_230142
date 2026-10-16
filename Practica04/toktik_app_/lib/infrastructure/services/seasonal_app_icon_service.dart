import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';

/// Solicita cambiar el icono del launcher de Android mediante activity-alias.
/// Android deja el cambio pendiente hasta que la app pase al fondo para evitar
/// que algunos launchers terminen la actividad que el usuario está utilizando.
/// En Web no hay un icono instalado en el launcher que Flutter pueda cambiar.
class SeasonalAppIconService {
  SeasonalAppIconService._();

  static const MethodChannel _channel = MethodChannel('toktik/seasonal_icon');

  static Future<void> apply(AppSeason season) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod<bool>(
        'setLauncherIcon',
        <String, String>{'season': season.name},
      );
    } on MissingPluginException catch (error) {
      debugPrint('El icono estacional nativo todavía no está instalado: $error');
    } on PlatformException catch (error) {
      debugPrint('No se pudo cambiar el icono de TokTik: ${error.message}');
    } catch (error) {
      debugPrint('Error al cambiar el icono de TokTik: $error');
    }
  }
}
