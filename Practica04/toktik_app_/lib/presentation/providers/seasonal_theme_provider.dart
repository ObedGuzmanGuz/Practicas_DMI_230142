import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:toktik_app/config/theme/seasonal_theme.dart';
import 'package:toktik_app/infrastructure/storage/local_settings_storage.dart';
import 'package:toktik_app/infrastructure/services/seasonal_app_icon_service.dart';

class SeasonalThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  SeasonalThemeProvider({LocalSettingsStorage? storage, DateTime Function()? clock})
      : _storage = storage ?? LocalSettingsStorage(),
        _clock = clock ?? DateTime.now {
    // La primera apertura conserva el tema Normal; si el usuario activa
    // Automático, la fecha del dispositivo se supervisa en segundo plano.
    _season = AppSeason.normal;
    WidgetsBinding.instance.addObserver(this);
  }

  final LocalSettingsStorage _storage;
  final DateTime Function() _clock;
  AudioPlayer? _audioPlayer;
  Timer? _audioStopTimer;
  Timer? _seasonRefreshTimer;
  SeasonMode _mode = SeasonMode.normal;
  late AppSeason _season;
  int _changeRevision = 0;
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
    _startSeasonDateWatcher();
    // Sincroniza el icono con las preferencias restauradas al iniciar la app.
    await SeasonalAppIconService.apply(_season);
    // Arranca la melodía antes de marcar la inicialización como lista para que
    // el splash pueda contar sus cinco segundos desde el inicio del audio.
    await _playSeasonSound(_season);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setMode(SeasonMode mode) async {
    final revision = ++_changeRevision;
    final previousSeason = _season;
    _mode = mode;
    _updateSeason();
    final selectedSeason = _season;

    // La interfaz se actualiza inmediatamente; el almacenamiento, el icono y
    // el audio se sincronizan en el mismo orden que las selecciones del usuario.
    notifyListeners();
    await _storage.saveSeasonMode(mode.name);
    if (revision != _changeRevision) return;

    await SeasonalAppIconService.apply(selectedSeason);
    if (revision != _changeRevision) return;

    if (previousSeason != selectedSeason) {
      await _stopCurrentAudio();
      // Si mientras se detenía el audio se eligió otro tema, no reproducir el anterior.
      if (revision == _changeRevision && selectedSeason == _season) {
        await _playSeasonSound(selectedSeason);
      }
    }
  }

  void _startSeasonDateWatcher() {
    _seasonRefreshTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshSeasonFromDeviceDate()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Cubre el caso en que el usuario cambia la fecha desde Ajustes y regresa
      // a TokTik, incluso si Android no recreó el proceso de Flutter.
      unawaited(_refreshSeasonFromDeviceDate(forceIconSync: true));
    }
  }

  Future<void> _refreshSeasonFromDeviceDate({bool forceIconSync = false}) async {
    if (_mode != SeasonMode.automatic) {
      if (forceIconSync) await SeasonalAppIconService.apply(_season);
      return;
    }

    final previousSeason = _season;
    _updateSeason();
    final selectedSeason = _season;
    if (selectedSeason == previousSeason) {
      if (forceIconSync) await SeasonalAppIconService.apply(selectedSeason);
      return;
    }

    final revision = ++_changeRevision;
    notifyListeners();
    await SeasonalAppIconService.apply(selectedSeason);
    if (revision != _changeRevision || selectedSeason != _season) return;

    await _stopCurrentAudio();
    if (revision == _changeRevision && selectedSeason == _season) {
      await _playSeasonSound(selectedSeason);
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
    WidgetsBinding.instance.removeObserver(this);
    _seasonRefreshTimer?.cancel();
    _audioStopTimer?.cancel();
    final player = _audioPlayer;
    if (player != null) unawaited(player.dispose());
    super.dispose();
  }
}
