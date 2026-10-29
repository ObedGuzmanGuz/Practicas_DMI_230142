# Cinemapedia App

Aplicación Flutter de consulta de películas con datos de **The Movie Database (TMDB)**.

## Requisitos

- Flutter y Dart instalados.
- Una API Key de TMDB.

## Configuración inicial

1. Abre una terminal en la carpeta `cinemapedia_app`.
2. Copia `.env.template` y crea un archivo llamado `.env` (ya se incluye uno vacío como plantilla local).
3. Dentro de `.env`, agrega tu clave:

   ```env
   THE_MOVIEDB_KEY=TU_API_KEY_DE_TMDB
   ```

4. Instala las dependencias:

   ```bash
   flutter pub get
   ```

5. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

Puedes obtener una API Key desde la configuración de tu cuenta de TMDB: https://www.themoviedb.org/settings/api

## Funcionalidades integradas

- Listados de películas en cartelera, populares, próximas y mejor calificadas.
- Carrusel de películas destacadas.
- Búsqueda de películas.
- Pantalla de detalle de película.
- Consulta del reparto y presentación de actores.
- Menú hamburguesa con selector de país e idioma: México (Español), Estados Unidos (English), Japón (日本語) y Alemania (Deutsch).
- Actualización del idioma de la interfaz y de los títulos/sinopsis disponibles en TMDB.
- Filtro regional de TMDB y clasificación por edades según el país seleccionado.
- Calificación visual de películas con cinco estrellas y puntuación numérica.
- Paginación de los listados y navegación con GoRouter.
- Gestión de estado con Riverpod; al cambiar de país se vuelven a cargar los listados y las búsquedas usan la nueva región.

## Estructura

- `lib/config`: configuración, rutas, formato y tema.
- `lib/domain`: entidades, contratos de datos y repositorios.
- `lib/infrastructure`: comunicación con TMDB, modelos y mapeadores.
- `lib/presentation`: pantallas, widgets y providers.

> El archivo `.env` contiene la clave privada y está excluido de Git mediante `.gitignore`. No publiques tu API Key en el repositorio.
