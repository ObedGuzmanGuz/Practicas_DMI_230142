# 🎬 Cinemapedia App

Aplicación móvil multiplataforma desarrollada con **Flutter y Dart** que permite explorar, buscar y consultar información de películas mediante la API de **[The Movie Database (TMDB)](https://www.themoviedb.org/)**.

Cinemapedia ofrece una experiencia cinematográfica con información localizada por país, categorías, películas favoritas y una interfaz personalizable.

**Eslogan:** *Descubre, disfruta y vive el cine.*

## 🚀 Requisitos

- Flutter SDK instalado.
- Dart SDK.
- Visual Studio Code o Android Studio.
- Una API Key de TMDB.
- Conexión a internet para consultar la información de películas.

## ⚙️ Configuración inicial

1. Abre una terminal dentro de la carpeta `cinemapedia_app`.
2. Copia el archivo `.env.template` y crea un archivo llamado `.env`.
3. Dentro de `.env`, agrega tu API Key:

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

Para ejecutar la versión web en Chrome:

```bash
flutter run -d chrome
```

Puedes obtener tu API Key desde la configuración de tu cuenta de TMDB:

https://www.themoviedb.org/settings/api

## ✨ Funcionalidades

### 🎥 Exploración de películas
- Listados de películas en cartelera, populares, próximas y mejor calificadas.
- Carrusel de películas destacadas.
- Tarjetas con póster, título y calificación visual mediante estrellas.
- Pantalla de detalles con sinopsis, géneros y clasificación por edades.
- Consulta del reparto y presentación de actores.
- Paginación de los listados.

### 🔎 Búsqueda
- Buscador de películas mediante la API de TMDB.
- Consulta de resultados según el país e idioma seleccionados.

### 🌎 País e idioma
- Menú hamburguesa con selector regional.
- México (Español).
- Estados Unidos (English).
- Japón (日本語).
- Alemania (Deutsch).
- Actualización del idioma de la interfaz y de los datos disponibles de las películas.
- Consulta de información regional y clasificación por edades según el país seleccionado.

### 🎭 Categorías
- Exploración de películas por género.
- Consulta de películas relacionadas con cada categoría.
- Obtención de géneros y resultados desde TMDB.

### ❤️ Favoritos
- Agregar y quitar películas de la lista de favoritos.
- Acceso a una sección independiente de películas favoritas.
- Conservación de los favoritos mediante almacenamiento local.

### 🎨 Apariencia e identidad visual
- Identidad gráfica personalizada de Cinemapedia.
- Icono de aplicación inspirado en un ojo cinematográfico de estilo macabro.
- Modo claro y modo oscuro.
- Preferencia de apariencia conservada en el dispositivo.
- Interfaz con elementos visuales inspirados en el mundo del cine.

## 🛠️ Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo de la aplicación |
| Dart | Lenguaje de programación |
| TMDB API | Consulta de información cinematográfica |
| Riverpod | Gestión de estado |
| GoRouter | Navegación y rutas |
| Dio | Solicitudes HTTP |
| Flutter Dotenv | Configuración de variables de entorno |

## 📁 Estructura del proyecto

```text
cinemapedia_app/
│
├── android/
├── ios/
├── web/
├── windows/
├── macos/
├── linux/
│
├── assets/
│   └── ...
│
├── lib/
│   ├── config/
│   │   └── Configuración, rutas y temas
│   │
│   ├── domain/
│   │   └── Entidades, contratos y repositorios
│   │
│   ├── infrastructure/
│   │   └── Conexión con TMDB, modelos y mapeadores
│   │
│   └── presentation/
│       └── Pantallas, widgets y providers
│
├── test/
├── .env.template
├── .gitignore
├── pubspec.yaml
└── README.md
```

## 🔐 Seguridad

El archivo `.env` contiene la API Key de TMDB y debe mantenerse privado.

- El archivo `.env` está excluido del repositorio mediante `.gitignore`.
- Utiliza `.env.template` como plantilla de configuración.
- No publiques tu API Key en GitHub ni la compartas en capturas de pantalla.
- Cada desarrollador debe configurar su propia API Key para ejecutar el proyecto.

## ▶️ Comandos útiles

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar la aplicación:

```bash
flutter run
```

Ejecutar en Chrome:

```bash
flutter run -d chrome
```

Verificar errores y advertencias:

```bash
flutter analyze
```

Ejecutar pruebas:

```bash
flutter test
```

Limpiar archivos de compilación:

```bash
flutter clean
```

---

**Cinemapedia App**

*Descubre, disfruta y vive el cine.* 🍿