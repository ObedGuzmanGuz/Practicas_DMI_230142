# TokTik Azul · Práctica 04

Aplicación Flutter que reproduce un feed vertical de videos inspirado en TikTok. Está organizada con Provider, entidades de dominio, repositorios, datasources, reproducción de videos y almacenamiento local mediante `SharedPreferences`.

## Funcionalidades

- **Tres feeds:** `Discover`, `For You` y `Favorites`. Se navega horizontalmente entre secciones y verticalmente entre videos.
- **Discover:** mezcla los videos MP4 del catálogo Cloudinary con resultados en vivo de Pixabay y Coverr.
- **For You:** contiene exclusivamente resultados de YouTube Data API v3 y los reproduce mediante el reproductor oficial de YouTube.
- **Favorites:** solo muestra videos a los que el usuario dio Me gusta, sin importar de cuál feed provengan.
- **Likes y vistas persistentes:** los Me gusta se guardan localmente. Una vista se suma cuando cada reproducción comienza; se conserva el contador al volver a abrir la aplicación.
- **Paginación:** cuando el usuario se acerca al final, el Provider solicita páginas adicionales a las fuentes que admiten paginación.
- **Temas estacionales:** Automático, Normal, Halloween, Navidad y Valentine's Day. Cada tema cambia colores, el distintivo del logo y una melodía instrumental original de cinco segundos que se repite en bucle.
- **Controles:** silenciar/reanudar audio, expandir descripciones y desplazarse al video anterior o siguiente.

## Fuentes de video

| Fuente | Uso en la aplicación | Reproducción |
| --- | --- | --- |
| `CloudinaryVideoDataSource` | `Discover` | Archivos MP4 directos con `VideoPlayerController`. |
| `PixabayVideoDataSource` | `Discover` | Resultados de la API de Pixabay, con URL MP4 directa. |
| `CoverrVideoDataSource` | `Discover` | Resultados de la API de Coverr, con URL MP4 directa y atribución enlazada. |
| `YouTubeVideoDataSource` | `For You` | `search.list` obtiene videos; `videos.list` intenta obtener estadísticas públicas; el reproductor oficial detecta cuándo comienza cada reproducción. |

La API de YouTube no entrega un archivo MP4 directo. El proyecto utiliza su reproductor oficial incrustado y filtra por videos reproducibles mediante embed. Algunas publicaciones pueden dejar de estar disponibles o tener restricciones de reproducción.

## Temas y melodías

El selector superior abre un panel con tarjetas para cada temporada. Elegir una opción actualiza la paleta completa, el fondo del distintivo del logo y el emoji de temporada. La melodía cambia al seleccionar el tema y la preferencia permanece guardada en el dispositivo.

Reglas del modo automático:

| Tema | Fechas |
| --- | --- |
| Halloween | Octubre y del 1 al 2 de noviembre |
| Navidad | Diciembre |
| Valentine's Day | Del 1 al 14 de febrero |
| Normal | El resto del año |

Los archivos de audio están en `assets/audio/`. El botón de música de la barra superior permite silenciar y reanudar la melodía.

## Arquitectura

### 1. Providers locales y persistencia

`DiscoverProvider` gestiona los feeds, likes, vistas y el mute de los videos. `SeasonalThemeProvider` decide el tema por fecha o por selección manual y coordina la música. `LocalVideoStorage` y `LocalSettingsStorage` guardan la información con `SharedPreferences`.

![Arquitectura de providers locales](docs/diagramas/provider_local.png)

### 2. Provider, repositorio y datasources

`DiscoverProvider` usa el contrato `VideoRepository`. `CompositeVideoRepository` separa el catálogo de `Discover` y el catálogo de YouTube para `For You`, normaliza los mapas a `VideoPost` mediante `VideoPostMapper` y aplica el filtro de favoritos.

![Arquitectura del repositorio y datasources](docs/diagramas/provider_repository_datasources.png)

Los diagramas editables de Graphviz se encuentran en `docs/diagramas/*.dot`. La documentación ampliada está en [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## Clean Architecture aplicada

- **Domain:** entidad `VideoPost` y contrato `VideoRepository`.
- **Infrastructure:** datasources, modelos, mapper, repositorio compuesto y almacenamiento local.
- **Presentation:** providers, pantallas y widgets. La interfaz no consulta directamente las APIs.
- **Dependency inversion:** `DiscoverProvider` recibe `VideoRepository` por constructor para permitir la inyección de repositorios alternativos en pruebas.

## Configurar YouTube Data API v3

1. En Google Cloud Console, selecciona el proyecto asociado a la clave.
2. En **APIs y servicios → Biblioteca**, habilita **YouTube Data API v3**.
3. En **APIs y servicios → Credenciales**, confirma que la clave esté activa.
4. Restringe la clave a **YouTube Data API v3**. Si añades restricciones de aplicación, configura el identificador y la firma correctos de Android.
5. La clave de prueba se lee desde `lib/config/api_keys.dart`. Si clonas el repositorio y ese archivo no existe, copia `lib/config/api_keys.example.dart` con el nombre `api_keys.dart` y agrega tus propias claves.

Por seguridad, esa configuración local está en `.gitignore`. No publiques el archivo ni uses esta clave sin restricciones. Una clave incluida en una app móvil se puede extraer; para producción, utiliza un backend para las solicitudes. Si `For You` aparece vacío, comprueba que la API esté habilitada, que la clave sea válida y que haya cuota disponible.

## Ejecutar el proyecto

Desde la carpeta `toktik_app_`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Para ejecutarlo en Android, conecta el dispositivo con la depuración USB activada o inicia un emulador. Se requiere conexión a internet para las fuentes remotas. La primera carga puede tardar mientras se solicitan resultados de las APIs. Si el audio automático se bloquea en un navegador, toca la nota musical para reintentarlo.

## Persistencia

- `toktik_liked_videos`: identificadores de videos marcados con Me gusta.
- `toktik_video_views`: vistas acumuladas por video.
- `toktik_season_mode`: modo seleccionado (`automatic`, `normal`, `halloween`, `christmas` o `valentinesDay`).

La persistencia es local al dispositivo y puede perderse si se borran los datos de la aplicación o se desinstala.

Documentación de APIs: [YouTube Data API v3](https://developers.google.com/youtube/v3/docs) · [Pixabay API](https://pixabay.com/api/docs/) · [Coverr API](https://api.coverr.co/docs).


### Ajustes para Flutter Web (Chrome)

- Los reproductores embebidos del navegador usan un `iframe` HTML. Esto evita depender de `window.flutter_inappwebview_plugin`, que no existe en Flutter Web; Android/iOS mantienen la implementación con WebView.
- El feed **For You** se mantiene exclusivamente con resultados de YouTube Data API v3 y el video se abre mediante el reproductor oficial de YouTube.
- Las melodías de temporada se intentan reproducir una vez al abrir la aplicación, tienen un máximo de cinco segundos y no quedan en bucle. Cambiar de temporada solo actualiza la apariencia y detiene una melodía de inicio que aún estuviera sonando.
- Chrome puede bloquear audio automático por sus reglas del navegador. Si ocurre, usa el control de música una vez para conceder la interacción; ese control también limita la reproducción a cinco segundos.
- La interfaz utiliza iconos de Material en lugar de emojis de temporada para reducir advertencias de fuentes faltantes.

## Feed Para ti: YouTube Shorts

- La búsqueda usa `#shorts`, videos insertables y `videoDuration=short`; luego valida metadatos y excluye videos de más de 180 segundos.
- El reproductor oficial se usa con `controls=0` para quitar la barra de controles. YouTube todavía puede mostrar su marca o avisos propios; no deben cubrirse ni alterarse.
- YouTube Data API no proporciona el MP4 ni garantiza la orientación vertical. Por ello, la app solo puede aproximar un feed de Shorts a partir de la búsqueda y duración. Algunos creadores deshabilitan la reproducción insertada; en ese caso se muestra el código del reproductor y se puede deslizar al siguiente.
- Los mensajes `mali_gralloc`, `Dawn` y `cr_media` relacionados con micrófono/captura no necesariamente indican el fallo del video. Para diagnosticar una carga fallida, busca `No se pudieron cargar videos de YouTube`, `YouTube IFrame Player API error` o el código de error visible dentro del feed.
