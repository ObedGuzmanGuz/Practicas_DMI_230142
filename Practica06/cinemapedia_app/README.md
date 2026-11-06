# Cinemapedia

**Descubre, disfruta y vive el cine.**

Cinemapedia es una aplicación Flutter para explorar películas, consultar información regional y crear una colección personal de favoritas.

## Funciones principales

- Cartelera, próximos estrenos, películas populares y mejor calificadas.
- Búsqueda de películas mediante TMDB.
- Detalle de película con sinopsis, géneros, clasificación regional y reparto.
- Catálogo por categorías/ géneros consultado mediante `discover/movie` de TMDB.
- Favoritos guardados localmente en el dispositivo.
- Selector de región e idioma: México (Español), Estados Unidos (English), Japón (日本語) y Alemania (Deutsch).
- Tema claro y oscuro, con preferencia guardada en el dispositivo.
- Identidad visual Cinemapedia con icono de ojo cinematográfico.

## Requisitos

- Flutter SDK compatible con la restricción del proyecto.
- Dart incluido con Flutter.
- Una API Key de TMDB.

## Configuración

1. Copia `.env.template` como `.env` si todavía no existe.
2. Agrega tu API Key de TMDB:

```env
THE_MOVIEDB_KEY=TU_API_KEY
```

3. Instala las dependencias:

```bash
flutter pub get
```

4. Ejecuta la app:

```bash
flutter run
```

## Estructura

- `lib/config`: rutas, temas, región y textos.
- `lib/domain`: entidades, repositorios y contratos.
- `lib/infrastructure`: conexión con TMDB, modelos y mappers.
- `lib/presentation`: pantallas, widgets y providers Riverpod.
- `assets/images`: identidad visual e icono de la aplicación.

## Tecnologías

Flutter, Dart, Riverpod, GoRouter, Dio, Shared Preferences y The Movie Database (TMDB).
