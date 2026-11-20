import 'package:cinemapedia_app/config/constants/movie_region.dart';

class AppStrings {
  final MovieRegion region;
  const AppStrings(this.region);

  bool get _en => region.languageCode.startsWith('en');
  bool get _ja => region.languageCode.startsWith('ja');
  bool get _de => region.languageCode.startsWith('de');
  bool get _zh => region.languageCode.startsWith('zh');
  bool get _ar => region.languageCode.startsWith('ar');

  String _t(String es, String en, String ja, String de, String zh, String ar) =>
      _en ? en : _ja ? ja : _de ? de : _zh ? zh : _ar ? ar : es;

  String get nowPlaying => _t('En cines', 'Now playing', '上映中', 'Im Kino', '正在热映', 'يعرض الآن');
  String get upcoming => _t('Próximamente', 'Coming soon', '近日公開', 'Demnächst', '即将上映', 'قريباً');
  String get popular => _t('Populares', 'Popular', '人気作品', 'Beliebt', '热门', 'الأكثر شيوعاً');
  String get topRated => _t('Mejor calificadas', 'Top rated', '高評価', 'Bestbewertet', '高分榜', 'الأعلى تقييماً');
  String get allTime => _t('Desde siempre', 'All time', '歴代', 'Alle Zeiten', '全部', 'على الإطلاق');
  String get searchMovies => _t('Buscar películas o series', 'Search movies or series', '映画・シリーズを検索', 'Filme oder Serien suchen', '搜索电影或剧集', 'ابحث عن أفلام أو مسلسلات');
  String get chooseCountry => _t('Selecciona país e idioma', 'Choose country and language', '国と言語を選択', 'Land und Sprache wählen', '选择国家和语言', 'اختر البلد واللغة');
  String get regionalCatalog => _t('Catálogo por país', 'Regional catalog', '地域別カタログ', 'Katalog nach Region', '地区目录', 'كتالوج حسب المنطقة');
  String get genres => _t('Géneros', 'Genres', 'ジャンル', 'Genres', '类型', 'الأنواع');
  String get classification => _t('Clasificación por edades', 'Age rating', '年齢区分', 'Altersfreigabe', '年龄分级', 'التصنيف العمري');
  String get noClassification => _t('NR · Sin clasificación disponible', 'NR · Not rated', 'NR · 情報なし', 'NR · Keine Freigabe', 'NR · 暂无分级', 'NR · غير مصنف');
  String get cast => _t('Reparto', 'Cast', '出演者', 'Besetzung', '演员', 'طاقم التمثيل');
  String get pleaseWait => _t('Espera por favor', 'Please wait', 'お待ちください', 'Bitte warten', '请稍候', 'يرجى الانتظار');
  String get loadingMovies => _t('Cargando contenido...', 'Loading titles...', '読み込み中...', 'Inhalte werden geladen...', '正在加载内容...', 'جارٍ تحميل المحتوى...');
  String get noOverview => _t('Sinopsis no disponible en este idioma.', 'No synopsis available in this language.', 'この言語のあらすじはありません。', 'Keine Inhaltsangabe in dieser Sprache verfügbar.', '当前语言暂无简介。', 'لا يوجد ملخص بهذه اللغة.');
  String get rating => _t('Calificación', 'Rating', '評価', 'Bewertung', '评分', 'التقييم');
  String get tagline => _t('Descubre, disfruta y vive el cine.', 'Discover, enjoy and live cinema.', '映画を見つけ、楽しみ、体験しよう。', 'Entdecke, genieße und lebe das Kino.', '发现、享受并体验电影。', 'اكتشف السينما واستمتع بها وعشها.');
  String get favorites => _t('Favoritos', 'Favorites', 'お気に入り', 'Favoriten', '收藏', 'المفضلة');
  String get categories => _t('Categorías', 'Categories', 'カテゴリー', 'Kategorien', '分类', 'الفئات');
  String get exploreGenres => _t('Explora por categoría', 'Explore by genre', 'ジャンルから探す', 'Nach Genre entdecken', '按类型探索', 'اكتشف حسب النوع');
  String get chooseGenre => _t('Elige un género y encuentra tu próxima historia.', 'Choose a genre and find your next story.', 'ジャンルを選んで次のお気に入りを見つけよう。', 'Wähle ein Genre und entdecke deine nächste Geschichte.', '选择类型，发现下一部喜欢的作品。', 'اختر نوعاً واكتشف قصتك التالية.');
  String get favoritesSubtitle => _t('Tu colección personal.', 'Your personal collection.', 'あなただけのコレクション。', 'Deine persönliche Sammlung.', '你的私人收藏。', 'مجموعتك الشخصية.');
  String get noFavorites => _t('Todavía no tienes favoritos.', 'You have no favorites yet.', 'まだお気に入りはありません。', 'Du hast noch keine Favoriten.', '你还没有收藏内容。', 'ليس لديك عناصر مفضلة بعد.');
  String get addFavoritesHint => _t('Pulsa el corazón para guardar una película o serie.', 'Tap the heart to save a movie or series.', 'ハートをタップして保存しましょう。', 'Tippe auf das Herz, um Inhalte zu speichern.', '点击爱心即可收藏。', 'اضغط على القلب لحفظ فيلم أو مسلسل.');
  String get lightMode => _t('Modo claro', 'Light mode', 'ライトモード', 'Heller Modus', '浅色模式', 'الوضع الفاتح');
  String get darkMode => _t('Modo oscuro', 'Dark mode', 'ダークモード', 'Dunkler Modus', '深色模式', 'الوضع الداكن');
  String get appearance => _t('Apariencia', 'Appearance', '外観', 'Erscheinungsbild', '外观', 'المظهر');
  String get allGenres => _t('Todos los géneros', 'All genres', 'すべてのジャンル', 'Alle Genres', '全部类型', 'كل الأنواع');
  String get moviesFound => _t('Contenido de esta categoría', 'Titles in this genre', 'このジャンルの作品', 'Titel dieses Genres', '此类型内容', 'عناوين هذا النوع');
  String get home => _t('Inicio', 'Home', 'ホーム', 'Start', '首页', 'الرئيسية');
  String get homeIntro => _t('Tu próxima historia favorita está a un toque.', 'Your next favorite story is one tap away.', '次のお気に入りの物語を見つけよう。', 'Deine nächste Lieblingsgeschichte ist nur einen Tipp entfernt.', '下一部心仪作品只需轻点一下。', 'قصتك المفضلة التالية على بعد لمسة.');
  String get movies => _t('Películas', 'Movies', '映画', 'Filme', '电影', 'أفلام');
  String get series => _t('Series', 'TV shows', 'シリーズ', 'Serien', '剧集', 'مسلسلات');
  String get onAir => _t('En emisión', 'On the air', '放送中', 'Läuft gerade', '正在播出', 'يعرض حالياً');
  String get upcomingSeries => _t('Próximamente', 'Coming soon', '近日配信', 'Demnächst', '即将开播', 'قريباً');
  String get content => _t('Contenido', 'Content', 'コンテンツ', 'Inhalt', '内容', 'المحتوى');
  String get settings => _t('Configuración', 'Settings', '設定', 'Einstellungen', '设置', 'الإعدادات');
  String get popularScreenSubtitle => _t('Lo que todos están viendo ahora.', 'What everyone is watching right now.', '今みんなが見ている作品。', 'Was gerade alle sehen.', '大家正在看的热门内容。', 'ما يشاهده الجميع الآن.');
  String get addToFavorites => _t('Agregar a favoritos', 'Add to favorites', 'お気に入りに追加', 'Zu Favoriten hinzufügen', '添加到收藏', 'أضف إلى المفضلة');
  String get removeFromFavorites => _t('Quitar de favoritos', 'Remove from favorites', 'お気に入りから削除', 'Aus Favoriten entfernen', '从收藏中移除', 'إزالة من المفضلة');
  String get previousCarousel => _t('Anterior · doble toque: inicio', 'Previous · double tap: first', '前へ · ダブルタップ: 最初', 'Zurück · Doppeltippen: Anfang', '上一个 · 双击：开头', 'السابق · نقرتان: البداية');
  String get nextCarousel => _t('Siguiente · doble toque: final', 'Next · double tap: last', '次へ · ダブルタップ: 最後', 'Weiter · Doppeltippen: Ende', '下一个 · 双击：末尾', 'التالي · نقرتان: النهاية');
  String get similarLoadError => _t('No se pudieron cargar recomendaciones.', 'Recommendations could not be loaded.', 'おすすめを読み込めませんでした。', 'Empfehlungen konnten nicht geladen werden.', '无法加载推荐内容。', 'تعذر تحميل التوصيات.');
  String get trailer => _t('Tráiler', 'Trailer', '予告編', 'Trailer', '预告片', 'الإعلان');
  String get similar => _t('También te puede gustar', 'You may also like', 'こちらもおすすめ', 'Das könnte dir auch gefallen', '你可能也喜欢', 'قد يعجبك أيضاً');
  String get releaseDate => _t('Estreno', 'Release date', '公開日', 'Erscheinungsdatum', '上映日期', 'تاريخ الإصدار');
  String get emptySearch => _t('Busca algo que te guste y aparecerá aquí.', 'Search for something you like.', '好きな作品を検索してください。', 'Suche nach einem Titel.', '搜索你喜欢的内容。', 'ابحث عن شيء يعجبك.');
  String get retry => _t('Reintentar', 'Try again', '再試行', 'Erneut versuchen', '重试', 'حاول مرة أخرى');
  String get catalogLoadError => _t('No se pudo cargar el catálogo. Verifica tu conexión y configura THE_MOVIEDB_KEY en .env.', 'The catalog could not load. Check your connection and configure THE_MOVIEDB_KEY in .env.', 'カタログを読み込めません。接続と.envのAPIキーを確認してください。', 'Der Katalog konnte nicht geladen werden. Prüfe Verbindung und API-Key in .env.', '无法加载目录。请检查网络并在.env中设置API密钥。', 'تعذر تحميل الكتالوج. تحقق من الاتصال ومفتاح API في .env.');
  String get detailLoadError => _t('No se pudo cargar el detalle. Revisa tu conexión y la API Key de TMDB.', 'Details could not load. Check your connection and TMDB API key.', '詳細を読み込めません。接続とTMDB APIキーを確認してください。', 'Details konnten nicht geladen werden. Prüfe Verbindung und TMDB API-Key.', '无法加载详情。请检查网络和TMDB API密钥。', 'تعذر تحميل التفاصيل. تحقق من الاتصال ومفتاح TMDB.');
  String get watchOnYoutube => _t('Abrir en YouTube', 'Open in YouTube', 'YouTubeで開く', 'Auf YouTube öffnen', '在 YouTube 打开', 'فتح في YouTube');
  String get trailerFallback => _t('Si el reproductor no inicia, abre el tráiler directamente en YouTube.', 'If the player does not start, open the trailer directly on YouTube.', '再生されない場合はYouTubeで開いてください。', 'Wenn der Player nicht startet, öffne den Trailer direkt auf YouTube.', '如果播放器无法启动，请直接在 YouTube 打开预告片。', 'إذا لم يبدأ المشغل، افتح الإعلان مباشرة على YouTube.');
  String get noTrailer => _t('No hay tráiler disponible para este título.', 'No trailer is available for this title.', 'この作品の予告編はありません。', 'Für diesen Titel ist kein Trailer verfügbar.', '此作品暂无预告片。', 'لا يتوفر إعلان لهذا العنوان.');
  String get noSimilar => _t('No hay títulos similares disponibles.', 'No similar titles are available.', '類似作品はありません。', 'Keine ähnlichen Titel verfügbar.', '暂无相似作品。', 'لا توجد عناوين مشابهة.');
  String get noCast => _t('No se encontró información del reparto.', 'Cast information is unavailable.', '出演者情報はありません。', 'Keine Besetzungsinformationen verfügbar.', '暂无演职人员信息。', 'لا تتوفر معلومات عن طاقم التمثيل.');
  String get categoryEmpty => _t('No hay contenido para mostrar en esta categoría.', 'There is no content in this category.', 'このカテゴリーには作品がありません。', 'In dieser Kategorie gibt es keine Inhalte.', '此类别暂无内容。', 'لا يوجد محتوى في هذه الفئة.');

}
