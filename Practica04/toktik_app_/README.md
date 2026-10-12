# TokTik Azul — Práctica 04

Aplicación Flutter que simula una red social de videos cortos con feeds verticales, temas estacionales y fuentes multimedia remotas.

[![Flutter](https://img.shields.io/badge/Flutter-multiplataforma-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Provider](https://img.shields.io/badge/estado-Provider-7B1FA2)](https://pub.dev/packages/provider)
[![Licencia](https://img.shields.io/badge/licencia-no%20especificada-lightgrey)]()

## Características

- Navegación horizontal entre Discover, For You y Favorites; desplazamiento vertical entre videos.
- `Provider` y `ChangeNotifier` para feeds, Me gusta, vistas personales, mute y temas.
- Temas Normal, Halloween, Navidad y Valentine's Day; modo automático por fecha del dispositivo.
- Reproducción de MP4 remotos y reproducción embebida oficial de YouTube.
- Likes, vistas personales y preferencia estacional persistidos localmente con `SharedPreferences`.

## Fuentes de datos

- **Discover:** catálogo de URLs Cloudinary definido en el proyecto, Pixabay API y Coverr API.
- **For You:** resultados de YouTube Data API v3 exclusivamente; no se mezclan con Discover.
- **Favorites:** videos con Me gusta activo, filtrados localmente.
- Los adaptadores de Vimeo y Dailymotion están definidos, pero no están activos en el repositorio compuesto predeterminado.

## Arquitectura

La presentación usa `DiscoverProvider` y `SeasonalThemeProvider`; el dominio define `VideoPost` y el contrato `VideoRepository`; la infraestructura compone fuentes, transforma registros con `VideoPostMapper`/`DriveVideoModel` y conserva preferencias en almacenamiento local.

- [Diagrama interactivo de arquitectura](../docs/arquitectura_interactiva.html) · [Documentación técnica](../docs/ARQUITECTURA.md)

## Requisitos e instalación

Se requiere Flutter/Dart compatible con las restricciones indicadas en [`pubspec.yaml`](pubspec.yaml), además de las herramientas nativas del destino elegido.

```bash
flutter pub get
```

La aplicación importa `lib/config/api_keys.dart`, archivo local excluido de Git. Si no existe, crea una copia desde la plantilla y agrega las claves necesarias:

```bash
cp lib/config/api_keys.example.dart lib/config/api_keys.dart
```

Rellena `ApiKeys.pixabay`, `ApiKeys.coverr` y `ApiKeys.youtube`. No publiques ese archivo ni incorpores claves reales al repositorio. Sin clave, esas fuentes devuelven listas vacías; el catálogo Cloudinary puede seguir apareciendo. Para iniciar en un destino configurado:

```bash
flutter run
```

## Plataformas

El proyecto contiene los destinos Android, iOS, Web, Windows, Linux y macOS. La compatibilidad final depende de cada plugin. La reproducción MP4 de `FullScreenPlayer` está implementada para Android, iOS, macOS y Web; Windows/Linux de escritorio no están soportados por ese reproductor. Los directorios de plataforma no prueban que cada destino se haya ejecutado.

## Desarrollo y documentación

Git controla versiones; GitHub es el remoto configurado para la práctica. La publicación por GitHub Pages no tiene configuración comprobable en este checkout, así que no hay enlace publicado que pueda afirmarse. Consulta la [arquitectura interactiva](../docs/arquitectura_interactiva.html) y [documentación técnica](../docs/ARQUITECTURA.md).

## Referencias oficiales

- [Flutter: plataformas soportadas](https://docs.flutter.dev/reference/supported-platforms) y [configuración de Flutter](https://docs.flutter.dev/install).
- [Dart](https://dart.dev/), [Provider](https://pub.dev/packages/provider), [`video_player`](https://pub.dev/packages/video_player), [`shared_preferences`](https://pub.dev/packages/shared_preferences) y [`audioplayers`](https://pub.dev/packages/audioplayers).
- [YouTube Data API `search.list`](https://developers.google.com/youtube/v3/docs/search/list), [`videos.list`](https://developers.google.com/youtube/v3/docs/videos/list) y [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference).
- [Pixabay API](https://pixabay.com/api/docs/). Para el acceso de Coverr, consulta [Coverr](https://coverr.co/) y las condiciones de la cuenta/API que proporcione la clave.
- [Cloudinary Video](https://cloudinary.com/documentation/video_manipulation_and_delivery).
- [Archify](https://github.com/tt-a1i/archify).
