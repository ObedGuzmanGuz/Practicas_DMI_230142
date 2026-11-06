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

  String get tagline => _english
      ? 'Discover, enjoy and live cinema.'
      : _japanese
          ? '映画を見つけ、楽しみ、体験しよう。'
          : _german
              ? 'Entdecke, genieße und lebe das Kino.'
              : 'Descubre, disfruta y vive el cine.';

  String get favorites => _english
      ? 'Favorites'
      : _japanese
          ? 'お気に入り'
          : _german
              ? 'Favoriten'
              : 'Favoritos';

  String get categories => _english
      ? 'Categories'
      : _japanese
          ? 'カテゴリー'
          : _german
              ? 'Kategorien'
              : 'Categorías';

  String get exploreGenres => _english
      ? 'Explore by genre'
      : _japanese
          ? 'ジャンルから探す'
          : _german
              ? 'Nach Genre entdecken'
              : 'Explora por categoría';

  String get chooseGenre => _english
      ? 'Choose a genre and find your next movie.'
      : _japanese
          ? 'ジャンルを選んで次のお気に入りを見つけよう。'
          : _german
              ? 'Wähle ein Genre und entdecke deinen nächsten Film.'
              : 'Elige un género y encuentra tu próxima película.';

  String get favoritesSubtitle => _english
      ? 'Your personal movie collection.'
      : _japanese
          ? 'あなただけの映画コレクション。'
          : _german
              ? 'Deine persönliche Filmsammlung.'
              : 'Tu colección personal de películas.';

  String get noFavorites => _english
      ? 'You have not saved any movies yet.'
      : _japanese
          ? 'まだ映画を保存していません。'
          : _german
              ? 'Du hast noch keine Filme gespeichert.'
              : 'Todavía no tienes películas favoritas.';

  String get addFavoritesHint => _english
      ? 'Tap the heart on a movie to save it here.'
      : _japanese
          ? '映画のハートをタップしてここに保存しよう。'
          : _german
              ? 'Tippe auf das Herz eines Films, um ihn hier zu speichern.'
              : 'Pulsa el corazón de una película para guardarla aquí.';

  String get lightMode => _english
      ? 'Light mode'
      : _japanese
          ? 'ライトモード'
          : _german
              ? 'Heller Modus'
              : 'Modo claro';

  String get darkMode => _english
      ? 'Dark mode'
      : _japanese
          ? 'ダークモード'
          : _german
              ? 'Dunkler Modus'
              : 'Modo oscuro';

  String get appearance => _english
      ? 'Appearance'
      : _japanese
          ? '外観'
          : _german
              ? 'Erscheinungsbild'
              : 'Apariencia';

  String get allGenres => _english
      ? 'All genres'
      : _japanese
          ? 'すべてのジャンル'
          : _german
              ? 'Alle Genres'
              : 'Todos los géneros';

  String get moviesFound => _english
      ? 'Movies for this genre'
      : _japanese
          ? 'このジャンルの映画'
          : _german
              ? 'Filme dieses Genres'
              : 'Películas de esta categoría';
  String get home => _english
      ? 'Home'
      : _japanese
          ? 'ホーム'
          : _german
              ? 'Start'
              : 'Inicio';

  String get homeIntro => _english
      ? 'Your next favorite story is one tap away.'
      : _japanese
          ? '次のお気に入りの物語を見つけよう。'
          : _german
              ? 'Deine nächste Lieblingsgeschichte ist nur einen Tipp entfernt.'
              : 'Tu próxima historia favorita está a un toque.';

}
