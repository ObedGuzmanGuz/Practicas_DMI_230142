# Arquitectura interactiva · Laboratorio Digital

Sitio estático y autocontenido para estudiar la arquitectura Flutter/Dart de la práctica. No necesita backend, claves ni servicios de ejecución; los enlaces de código conducen al remoto GitHub configurado. [`architecture.archify.html`](architecture.archify.html) es la exportación HTML independiente de Archify con el flujo principal; `index.html` añade fichas detalladas para cada bloque.

## Visualizar

Abre `docs/index.html` directamente en un navegador moderno o publica la carpeta `docs/`. Si el navegador restringe la carga local de JSON, sirve el repositorio con cualquier servidor estático local, por ejemplo `py -m http.server 8000` desde la raíz, y visita `http://localhost:8000/docs/`.

Arrastra el lienzo para desplazarte, usa la rueda o los controles `+`/`−` para cambiar el zoom. Todos los bloques se pueden activar con ratón, Tab y Enter. El panel lateral muestra la descripción, símbolos, archivos, rangos y enlace a GitHub.

## GitHub Pages

La práctica vive en un subdirectorio del repositorio; por ello `docs/` no está en la raíz Git y no puede seleccionarse como `/docs` con **Deploy from a branch**. Para activar Pages:

1. Copia [`deploy-pages.yml`](deploy-pages.yml) a `.github/workflows/deploy-pages.yml` en la raíz del repositorio `Practicas_DMI_230142`.
2. Sube ese workflow y los archivos de la práctica a la rama `Practica05`.
3. En GitHub abre **Settings → Pages** y selecciona **GitHub Actions** como fuente de despliegue.
4. Ejecuta el workflow **Publish architecture site** o espera un cambio posterior en `Practica05/widgets-app/docs/`.
5. Verifica que Actions termine en verde y abre la URL. La URL esperada es <https://obedguzmanguz.github.io/Practicas_DMI_230142/>; no se comprobó que ya esté publicada.

La URL, rama, prefijo `Practica05/widgets-app` y remoto están centralizados en [`repository.json`](repository.json). Para otro remoto actualiza ese archivo; las fichas construyen sus enlaces desde estos valores. `pagesVerified` permanece `false` hasta comprobar la publicación.

## Fuente del diagrama

[`architecture.archify.json`](architecture.archify.json) es la especificación editable de arquitectura Archify. [`assets/components.json`](assets/components.json) contiene los bloques detallados, relaciones visibles y evidencia con rangos de líneas que alimenta el inspector. El renderer interactivo del sitio es [`assets/app.js`](assets/app.js) y su presentación está en [`assets/styles.css`](assets/styles.css).

El diagrama representa destinos de compilación de una sola aplicación. El código revisado no evidencia backend, API propia, base de datos, Firebase, autenticación ni persistencia. Las imágenes remotas son dependencias externas de red; la galería desplazable agrega elementos en memoria.
