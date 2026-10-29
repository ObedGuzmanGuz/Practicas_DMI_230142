import 'package:cinemapedia_app/config/constants/movie_region.dart';

/// Textos breves de la interfaz para los cuatro idiomas disponibles.
/// Los títulos, sinopsis y géneros de las películas los entrega TMDB.
class AppStrings {
  final MovieRegion region;
  const AppStrings(this.region);

  bool get _english => region.isoCode == 'US';
  bool get _japanese => region.isoCode == 'JP';
  bool get _german => region.isoCode == 'DE';

  String get nowPlaying => _english
      ? 'Now playing'
      : _japanese
          ? '上映中'
          : _german
              ? 'Im Kino'
              : 'En cines';

  String get upcoming => _english
      ? 'Coming soon'
      : _japanese
          ? '近日公開'
          : _german
              ? 'Demnächst'
              : 'Próximamente';

  String get popular => _english
      ? 'Popular'
      : _japanese
          ? '人気作品'
          : _german
              ? 'Beliebt'
              : 'Populares';

  String get topRated => _english
      ? 'Top rated'
      : _japanese
          ? '高評価'
          : _german
              ? 'Bestbewertet'
              : 'Mejor calificadas';

  String get allTime => _english
      ? 'All time'
      : _japanese
          ? '歴代'
          : _german
              ? 'Alle Zeiten'
              : 'Desde siempre';

  String get searchMovies => _english
      ? 'Search movies'
      : _japanese
          ? '映画を検索'
          : _german
              ? 'Filme suchen'
              : 'Buscar películas';

  String get chooseCountry => _english
      ? 'Choose country and language'
      : _japanese
          ? '国と言語を選択'
          : _german
              ? 'Land und Sprache wählen'
              : 'Selecciona país e idioma';

  String get regionalCatalog => _english
      ? 'Regional catalog'
      : _japanese
          ? '地域別カタログ'
          : _german
              ? 'Katalog nach Region'
              : 'Catálogo por país';

  String get genres => _english
      ? 'Genres'
      : _japanese
          ? 'ジャンル'
          : _german
              ? 'Genres'
              : 'Géneros';

  String get classification => _english
      ? 'Age rating'
      : _japanese
          ? '年齢区分'
          : _german
              ? 'Altersfreigabe'
              : 'Clasificación por edades';

  String get noClassification => _english
      ? 'Not available for this country'
      : _japanese
          ? 'この国では情報がありません'
          : _german
              ? 'Für dieses Land nicht verfügbar'
              : 'No disponible para este país';

  String get cast => _english
      ? 'Cast'
      : _japanese
          ? '出演者'
          : _german
              ? 'Besetzung'
              : 'Reparto';

  String get pleaseWait => _english
      ? 'Please wait'
      : _japanese
          ? 'お待ちください'
          : _german
              ? 'Bitte warten'
              : 'Espera por favor';

  String get loadingMovies => _english
      ? 'Loading movies...'
      : _japanese
          ? '映画を読み込み中...'
          : _german
              ? 'Filme werden geladen...'
              : 'Cargando películas...';

  String get noOverview => _english
      ? 'No synopsis available in this language.'
      : _japanese
          ? 'この言語のあらすじはありません。'
          : _german
              ? 'Keine Inhaltsangabe in dieser Sprache verfügbar.'
              : 'Sinopsis no disponible en este idioma.';

  String get rating => _english
      ? 'Rating'
      : _japanese
          ? '評価'
          : _german
              ? 'Bewertung'
              : 'Calificación';
}
