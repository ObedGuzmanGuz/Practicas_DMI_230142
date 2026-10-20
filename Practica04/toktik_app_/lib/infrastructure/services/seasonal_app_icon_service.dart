import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';

/// Sincroniza el icono del launcher de Android con el tema activo.
/// Las solicitudes se ejecutan en serie: si se seleccionan varios temas seguidos,
/// la última selección siempre queda aplicada al finalizar la cola.
class SeasonalAppIconService {
  SeasonalAppIconService._();

  static const MethodChannel _channel = MethodChannel('toktik/seasonal_icon');
  static Future<void> _queue = Future<void>.value();

  static Future<void> apply(AppSeason season) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return Future<void>.value();
    }

    final request = _queue.then((_) async {
      try {
        final applied = await _channel.invokeMethod<bool>(
          'setLauncherIcon',
          <String, String>{'season': season.name},
        );
        if (applied != true) {
          debugPrint('Android no confirmó el cambio del icono para ${season.name}.');
        }
      } on MissingPluginException catch (error) {
        debugPrint('El icono estacional nativo todavía no está instalado: $error');
      } on PlatformException catch (error) {
        debugPrint('No se pudo cambiar el icono de TokTik: ${error.message}');
      } catch (error) {
        debugPrint('Error al cambiar el icono de TokTik: $error');
      }
    });

    _queue = request;
    return request;
  }
}
