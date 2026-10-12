# Arquitectura de TokTik Azul

El código de la aplicación se encuentra en [`../toktik_app_/`](../toktik_app_/). El mapa interactivo reúne las dos vistas en un mismo documento: [Abrir arquitectura interactiva](arquitectura_interactiva.html).

## 1. Providers locales y persistencia

`main.dart` registra `SeasonalThemeProvider` y `DiscoverProvider` en un `MultiProvider`. Los widgets consumen ambos estados y reaccionan a `notifyListeners()`.

- `DiscoverProvider` administra Discover, For You y Favorites; controla likes, vistas personales, mute, carga inicial y paginación. `LocalVideoStorage` lee y persiste likes y vistas en `SharedPreferences`.
- `SeasonalThemeProvider` administra el modo automático o manual. `seasonForDate()` usa la fecha del dispositivo en modo automático; `LocalSettingsStorage` conserva la preferencia. `SeasonalPalette` y `AppTheme` aplican Normal, Halloween, Navidad o Valentine's Day.
- Las melodías se reproducen desde `assets/audio/` con `audioplayers`. La interfaz selecciona `FullScreenPlayer` para URLs MP4 directas y `EmbeddedPlatformPlayer` para contenido marcado como embebido.
- El proyecto contiene destinos Android, iOS, Web, Windows, Linux y macOS. La compatibilidad multimedia depende de cada dependencia y plataforma; por ejemplo, el `FullScreenPlayer` declara Android, iOS, macOS y Web como compatibles.

## 2. Provider, repositorio y datasources

`DiscoverProvider` depende del contrato de dominio `VideoRepository`, cuya implementación predeterminada es `CompositeVideoRepository`. Este registra `CloudinaryVideoDataSource`, `PixabayVideoDataSource`, `CoverrVideoDataSource` y `YouTubeVideoDataSource`.

- `getDiscoverVideos()` combina las fuentes registradas excepto YouTube; para páginas posteriores conserva Pixabay y Coverr.
- `getYouTubeVideos()` consulta YouTube por separado. `ForYouFeedRepository` selecciona únicamente publicaciones cuya fuente es YouTube. `FavoritesFeedRepository` selecciona localmente las publicaciones con `isLiked`.
- `VideoPostMapper` delega la transformación a `DriveVideoModel`, que produce la entidad `VideoPost`.
- Cloudinary aporta un catálogo con URLs MP4; Pixabay y Coverr consultan sus APIs y devuelven URLs de video. YouTube Data API v3 usa `search.list` y `videos.list` para resultados, metadatos y estadísticas disponibles; el contenido se reproduce con el reproductor oficial embebido.
- `VimeoVideoDataSource` y `DailymotionVideoDataSource` están definidos en el código, pero no se registran en el `CompositeVideoRepository` predeterminado.
- `LocalVideoStorage` conserva likes y vistas personales en `SharedPreferences`; no escribe esas interacciones en las plataformas externas.

## Desarrollo y publicación

Git mantiene el control de versiones; GitHub es el remoto del repositorio. La configuración de GitHub Pages no está presente en este checkout, por lo que su publicación no se da por confirmada. Las especificaciones editables en formato Archify están en [`diagramas/`](diagramas/).

El README de la práctica enlaza este documento y el HTML interactivo. Las evidencias de interfaz permanecen en [`../Evidencias_toktik/`](../Evidencias_toktik/).

## Evidencias de los diagramas

- [Provider local y persistencia](diagramas/provider_local.png)
- [Provider, repositorios y datasources](diagramas/provider_repository_datasources.png)

Las imágenes son vistas previas; la [página interactiva](arquitectura_interactiva.html) contiene ambos mapas completos y permite alternarlos en el mismo documento. Los controles propios de Archify ofrecen zoom, paneo y restablecimiento. La interfaz fija de Archify está en inglés; los títulos y las etiquetas del proyecto están en español.

## Archivos editables y validación

Las especificaciones editables de Archify están en `diagramas/*.architecture.json`. Archify genera cada viewer SVG interactivo y ambos se integran, completos y autocontenidos, dentro de [`arquitectura_interactiva.html`](arquitectura_interactiva.html). La página exterior alterna entre ellos con pestañas sin recargar el documento; cada viewer conserva zoom, paneo, restablecimiento y sus controles propios.

Las dos especificaciones pasan las nueve comprobaciones de Archify con cero errores y cero advertencias de composición. La navegación exterior se implementa con HTML/CSS/JavaScript y no requiere rutas absolutas ni recursos locales externos. Las vistas del HTML se incrustan como documentos interactivos completos; cambiar de pestaña oculta una vista y muestra la otra sin cambiar de URL.
