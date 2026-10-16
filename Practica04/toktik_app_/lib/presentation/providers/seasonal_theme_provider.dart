import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';
import 'package:toktik_app/infrastructure/storage/local_settings_storage.dart';
import 'package:toktik_app/infrastructure/services/seasonal_app_icon_service.dart';

class SeasonalThemeProvider extends ChangeNotifier {
  SeasonalThemeProvider({LocalSettingsStorage? storage, DateTime Function()? clock})
      : _storage = storage ?? LocalSettingsStorage(),
        _clock = clock ?? DateTime.now {
    // La aplicación y el icono arrancan siempre en Normal si no hay una
    // preferencia guardada. El calendario solo se usa al elegir Automático.
    _season = AppSeason.normal;
  }

  final LocalSettingsStorage _storage;
  final DateTime Function() _clock;
  AudioPlayer? _audioPlayer;
  Timer? _audioStopTimer;
  SeasonMode _mode = SeasonMode.normal;
  late AppSeason _season;
  bool _initialized = false;
  bool _musicEnabled = true;

  SeasonMode get mode => _mode;
  AppSeason get season => _season;
  SeasonalPalette get palette => SeasonalPalette.forSeason(_season);
  bool get initialized => _initialized;
  bool get musicEnabled => _musicEnabled;

  String get modeLabel => _mode == SeasonMode.automatic
      ? 'Automático (fecha del dispositivo)'
      : switch (_mode) {
          SeasonMode.automatic => 'Automático (fecha del dispositivo)',
          SeasonMode.normal => 'Normal',
          SeasonMode.halloween => 'Halloween',
          SeasonMode.christmas => 'Navidad',
          SeasonMode.valentinesDay => "Valentine's Day",
        };

  Future<void> initialize() async {
    final saved = await _storage.loadSeasonMode();
    _mode = SeasonMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => SeasonMode.normal,
    );
    _updateSeason();
    // Sincroniza el icono nativo con el tema restaurado. El canal aplica el
    // alias seleccionado y mantiene otro intento al salir como respaldo.
    unawaited(SeasonalAppIconService.apply(_season));
    // Arranca la melodía antes de marcar la inicialización como lista para que
    // el splash pueda contar sus cinco segundos desde el inicio del audio.
    await _playSeasonSound(_season);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setMode(SeasonMode mode) async {
    final previousSeason = _season;
    _mode = mode;
    _updateSeason();

    // La paleta, los sonidos y el icono corresponden al tema elegido.
    notifyListeners();

    await _storage.saveSeasonMode(mode.name);
    unawaited(SeasonalAppIconService.apply(_season));

    // Cada tema tiene su propio sonido. Al cambiar de temporada detenemos
    // cualquier audio anterior y reproducimos el efecto correspondiente.
    if (previousSeason != _season) {
      final selectedSeason = _season;
      unawaited(() async {
        await _stopCurrentAudio();
        // Si el usuario cambia otra vez de tema mientras se detiene el audio,
        // no iniciar una pista que ya dejó de estar seleccionada.
        if (selectedSeason == _season) {
          await _playSeasonSound(selectedSeason);
        }
      }());
    }
  }

  Future<void> toggleMusic() async {
    if (_musicEnabled) {
      _musicEnabled = false;
      await _stopCurrentAudio();
      notifyListeners();
      return;
    }

    // Este botón es una acción explícita del usuario, útil si Chrome bloqueó el
    // autoplay. También reproduce solo un fragmento de cinco segundos.
    _musicEnabled = true;
    notifyListeners();
    await _playSeasonSound(_season);
  }

  void _updateSeason() {
    _season = switch (_mode) {
      SeasonMode.automatic => seasonForDate(_clock()),
      SeasonMode.normal => AppSeason.normal,
      SeasonMode.halloween => AppSeason.halloween,
      SeasonMode.christmas => AppSeason.christmas,
      SeasonMode.valentinesDay => AppSeason.valentinesDay,
    };
  }

  Future<void> _playSeasonSound(AppSeason season) async {
    if (!_musicEnabled) return;
    AudioPlayer? attemptedPlayer;
    try {
      _audioStopTimer?.cancel();
      final player = _audioPlayer ??= AudioPlayer();
      attemptedPlayer = player;
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(0.45);
      await player.stop();
      await player.play(AssetSource(season.audioAsset));
      _audioStopTimer = Timer(const Duration(seconds: 5), () {
        if (identical(_audioPlayer, player)) {
          unawaited(player.stop().catchError((Object error) {
            debugPrint('No se pudo detener el audio de temporada: $error');
          }));
        }
      });
    } catch (error) {
      // Chrome puede bloquear el sonido automático hasta que el usuario interactúe.
      _musicEnabled = false;
      final failedPlayer = attemptedPlayer ?? _audioPlayer;
      _audioPlayer = null;
      _audioStopTimer?.cancel();
      _audioStopTimer = null;
      if (failedPlayer != null) {
        try {
          await failedPlayer.dispose();
        } catch (_) {
          // En pruebas de widgets algunos plugins de plataforma no están disponibles.
        }
      }
      notifyListeners();
      debugPrint('No se pudo reproducir la música de temporada: $error');
    }
  }

  Future<void> _stopCurrentAudio() async {
    _audioStopTimer?.cancel();
    _audioStopTimer = null;
    try {
      await _audioPlayer?.stop();
    } catch (error) {
      debugPrint('No se pudo detener el audio de temporada: $error');
    }
  }

  @override
  void dispose() {
    _audioStopTimer?.cancel();
    final player = _audioPlayer;
    if (player != null) unawaited(player.dispose());
    super.dispose();
  }
}
