# Entorno de desarrollo Flutter - Yes No App

## Descripción

Este repositorio corresponde a una aplicación Flutter existente y a la preparación del entorno necesario para revisarla, ejecutarla en Android, realizar validaciones de código, utilizar Docker para tareas compatibles y publicar el proyecto en GitHub.

El manual de referencia utiliza como ruta de ejemplo `Practica-03/yes_no_app/`. La documentación se concentra en la instalación y configuración del entorno; no describe en detalle la funcionalidad interna de la aplicación.

## Objetivos

- Preparar Windows para el desarrollo móvil con Flutter.
- Instalar y verificar Flutter, Dart y las herramientas requeridas para Android.
- Revisar las dependencias y validar la aplicación existente en un emulador o dispositivo físico.
- Configurar Docker para ejecutar tareas compatibles, como análisis estático o pruebas.
- Mantener el código bajo control de versiones y publicarlo en GitHub.
- Documentar las verificaciones realizadas sin inventar resultados ni evidencias.

## Arquitectura del entorno

```text
Windows 10/11
├── Visual Studio Code
│   └── Flutter + Dart: edición, dependencias, análisis y ejecución
├── Android Studio
│   └── Android SDK + SDK Tools + Android Emulator
├── JDK 21 LTS
│   └── Entorno Java utilizado por la cadena de compilación Android mediante Gradle
├── Apache Maven 3.9.x
│   └── Herramienta Java adicional; no reemplaza a Gradle para compilar Android
├── Node.js LTS + npm
│   └── Herramientas disponibles en el entorno
└── WSL2 + Ubuntu 24.04 LTS (cuando se requiera)
    └── Docker Desktop + Docker Compose

Proyecto Flutter existente -> Validación local -> Dockerización de tareas compatibles -> Git -> GitHub
```

## Requisitos

### Hardware

**Mínimos indicados por el manual**

- Procesador con arquitectura x64.
- 8 GB de RAM.
- 30 GB de espacio libre.
- Virtualización habilitada.
- Conexión a Internet.

**Recomendados**

- Intel Core i5 / AMD Ryzen 5 o superior.
- 16 GB de RAM o más.
- Unidad SSD.
- 50 GB de espacio libre o más.
- Virtualización habilitada.

Android Studio, el emulador y Docker pueden consumir recursos al mismo tiempo. En equipos con memoria limitada, es conveniente cerrar las herramientas que no se utilicen o probar la aplicación en un dispositivo Android físico.

### Software

| Herramienta | Propósito |
|---|---|
| Windows 10/11 | Sistema operativo anfitrión. |
| WSL2 + Ubuntu 24.04 LTS | Entorno Linux y soporte para Docker cuando corresponda. |
| Visual Studio Code | Editor principal y terminal integrada. |
| Flutter Stable + Dart | Framework y lenguaje de la aplicación móvil. |
| Android Studio | Administración de Android SDK, herramientas y dispositivos virtuales. |
| Android SDK / SDK Tools / Emulator | Compilación y ejecución de la aplicación para Android. |
| JDK 21 LTS (Eclipse Temurin) | Entorno Java para la cadena Android/Gradle. |
| Apache Maven 3.9.x | Herramienta adicional para proyectos Java. |
| Node.js LTS + npm | Entorno de JavaScript y administración de paquetes. |
| Docker Desktop + Docker Compose | Construcción y ejecución de contenedores para tareas compatibles. |
| Git + GitHub | Control de versiones y publicación del repositorio. |

## Instalación y preparación del entorno

Se recomienda seguir este orden, comprobando cada herramienta antes de continuar.

1. **Revisar Windows y el hardware.** Confirmar la versión de Windows, la arquitectura x64 y que la virtualización esté habilitada.
2. **Configurar WSL2** si se necesita para Docker Desktop. Instalar Ubuntu 24.04 LTS y comprobar que utiliza la versión 2.
3. **Instalar Visual Studio Code** y las extensiones Flutter, Dart, WSL y Extension Pack for Java. La extensión de Docker es opcional.
4. **Instalar JDK 21 LTS** y verificar que Java esté disponible en `PATH` y que `JAVA_HOME` esté configurado.
5. **Instalar Apache Maven 3.9.x** y configurar `MAVEN_HOME` y `PATH`, según las indicaciones del manual.
6. **Instalar Node.js LTS y npm.**
7. **Instalar Android Studio**, configurar Android SDK y SDK Tools, y aceptar las licencias necesarias.
8. **Crear un dispositivo virtual Android (AVD)** con un perfil compatible con los recursos disponibles, o conectar un teléfono Android.
9. **Instalar Flutter Stable**, extraer el SDK y agregar su carpeta `bin` al `PATH` de Windows. El manual utiliza `C:\src\flutter\bin` como ejemplo de ruta.
10. **Instalar Docker Desktop** y comprobar que Docker Engine y Docker Compose estén disponibles.
11. **Validar la aplicación existente** antes de modificar la configuración para Docker.

### Verificar las herramientas

Ejecutar los comandos en CMD, PowerShell o la terminal integrada de Visual Studio Code, según corresponda:

```bash
java -version
mvn -version
node --version
npm --version
flutter --version
dart --version
flutter doctor
```

Para comprobar la configuración de Android y el dispositivo:

```bash
flutter doctor --android-licenses
flutter devices
```

También se pueden verificar Docker y Docker Compose:

```bash
docker --version
docker compose version
docker info
```

`docker info` debe mostrar información del cliente y del servidor; esto permite comprobar que Docker Engine está disponible.

## Validar la aplicación Flutter

Abrir en Visual Studio Code la carpeta raíz real del proyecto. La ruta de referencia del manual es `Practica-03/yes_no_app/`.

Antes de ejecutar comandos, comprobar que existan los archivos y carpetas correspondientes al proyecto Flutter, por ejemplo `lib/`, `android/`, `test/`, `pubspec.yaml` y `pubspec.lock`.

Desde la raíz del proyecto, ejecutar:

```bash
flutter pub get
flutter analyze
flutter test
flutter devices
```

- `flutter pub get` resuelve las dependencias declaradas en `pubspec.yaml`.
- `flutter analyze` analiza el código del proyecto.
- `flutter test` ejecuta las pruebas automatizadas disponibles.
- `flutter devices` muestra los emuladores o dispositivos reconocidos por Flutter.

Iniciar el emulador desde Android Studio o conectar un dispositivo físico autorizado. Después, ejecutar:

```bash
flutter run
```

**Resultado esperado:** la aplicación Flutter existente se ejecuta en Android. Si aparecen advertencias en `flutter doctor`, revisar el componente señalado y resolver los pendientes que afecten a la ejecución.

## Dockerización del proyecto

Docker se incorpora para tareas del proyecto que puedan ejecutarse dentro de un contenedor, como resolver dependencias, analizar el código o ejecutar pruebas compatibles. La configuración debe adaptarse a la versión real de Flutter del proyecto.

> **Importante:** Docker no sustituye a Android Studio ni al emulador. No se debe afirmar que el emulador Android o el APK se ejecutan dentro de un contenedor si eso no sucede en la configuración real. Tampoco se deben agregar bases de datos, APIs, servidores, puertos o microservicios que el proyecto no utilice.

### Archivos relacionados

- `Dockerfile`: define las instrucciones para construir una imagen y ejecutar la tarea elegida.
- `.dockerignore`: excluye archivos que no son necesarios para construir la imagen.
- `compose.yaml`: opcional; se utiliza si el proyecto necesita Docker Compose.

Ejemplo de `.dockerignore` basado en el manual:

```text
.git
.gitignore
.idea
.vscode
build
.dart_tool
*.log
```

La estructura ilustrativa del `Dockerfile` en el manual utiliza `FROM IMAGEN_FLUTTER_COMPATIBLE` como marcador de posición. Debe reemplazarse por una imagen real y compatible con la versión instalada de Flutter antes de construirla; no es una instrucción lista para copiar y ejecutar sin adaptación.

### Construir y probar la imagen

Después de configurar correctamente el `Dockerfile`, desde la raíz del proyecto:

```bash
docker build -t yes-no-app-flutter .
docker images
```

Para ejecutar el contenedor con el nombre de ejemplo del manual:

```bash
docker run --name yes-no-app-container yes-no-app-flutter
docker ps -a
docker logs yes-no-app-container
```

Si se ha configurado `compose.yaml`, se puede utilizar el flujo equivalente:

```bash
docker compose build
docker compose up
docker compose ps
docker compose logs
```

Al terminar, detener y eliminar el contenedor independiente o los servicios de Compose:

```bash
docker stop yes-no-app-container
docker rm yes-no-app-container
```

O, si se utilizó Docker Compose:

```bash
docker compose down
```

Los nombres `yes-no-app-flutter` y `yes-no-app-container` son los ejemplos usados por el manual; se pueden ajustar si el proyecto utiliza otros nombres.

## Publicar el proyecto en GitHub

Antes de publicar, revisar el estado del repositorio y el archivo `.gitignore`. No se deben incluir contraseñas, tokens, claves privadas, credenciales, archivos `.env` con secretos ni archivos temporales o de compilación.

### 1. Verificar Git

```bash
git --version
git status
```

Si el proyecto todavía no tiene repositorio Git, inicializarlo una sola vez:

```bash
git init
```

### 2. Preparar los cambios y crear el commit

```bash
git status
git add .
git status
git branch --show-current
```

Revisar que los archivos preparados sean los correctos antes de confirmar los cambios. El manual recomienda incluir el nombre real de la rama y una descripción en el commit. Ejemplo **solo si la rama se llama `main`**:

```bash
git commit -m "main - add" -m "Se agregó la configuración de Docker al proyecto Flutter."
```

### 3. Conectar y publicar el repositorio

Comprobar primero si ya existe un remoto:

```bash
git remote -v
```

Si no existe `origin`, agregar la URL real del repositorio:

```bash
git remote add origin URL_DEL_REPOSITORIO
```

Consultar el nombre de la rama y utilizarlo en el envío. Ejemplo únicamente si la rama se llama `main`:

```bash
git branch --show-current
git push -u origin main
```

Al finalizar, abrir el repositorio en GitHub y comprobar que los archivos y el commit estén visibles y que no se haya publicado información sensible.

## Solución de problemas frecuentes

| Problema | Qué revisar |
|---|---|
| `java` no se reconoce | Revisar la instalación del JDK, `PATH`, `JAVA_HOME` y abrir una terminal nueva. |
| `mvn` no se reconoce | Revisar `MAVEN_HOME` y que `%MAVEN_HOME%\bin` esté en `PATH`. |
| `flutter` no se reconoce | Confirmar que la carpeta `bin` del SDK esté en `PATH` y abrir una terminal nueva. |
| Flutter no detecta el dispositivo | Iniciar el emulador, revisar la conexión USB/autorización del teléfono y ejecutar `flutter devices` y `flutter doctor`. |
| WSL no inicia | Revisar `wsl --status` y `wsl --list --verbose`. |
| Docker no responde | Abrir Docker Desktop y verificar que Docker Engine esté activo. |
| Docker no conecta con WSL2 | Revisar la integración de WSL2 en la configuración de Docker Desktop. |
| El contenedor se detiene | Consultar `docker compose ps`, `docker compose logs` o `docker logs NOMBRE_CONTENEDOR`. |
| `git push` falla | Verificar la rama, el remoto `origin`, la autenticación y el estado del repositorio. |

## Checklist de validación

- [ ] Windows, arquitectura x64 y virtualización verificados.
- [ ] WSL2 configurado cuando sea necesario.
- [ ] Visual Studio Code y extensiones principales disponibles.
- [ ] JDK 21 y variables de entorno verificados.
- [ ] Maven 3.9.x instalado y reconocido.
- [ ] Node.js y npm reconocidos.
- [ ] Android Studio, Android SDK y SDK Tools configurados.
- [ ] Emulador o dispositivo Android disponible.
- [ ] Flutter y Dart reconocidos desde la terminal.
- [ ] `flutter doctor` revisado.
- [ ] Dependencias resueltas y análisis/pruebas revisados.
- [ ] Aplicación existente ejecutada en Android.
- [ ] Docker Engine y Docker Compose verificados.
- [ ] Imagen y contenedor comprobados si Docker forma parte del flujo real.
- [ ] `git status`, commit, remoto y publicación en GitHub verificados.
- [ ] Evidencias revisadas para evitar credenciales o datos sensibles.

Este checklist debe marcarse únicamente después de realizar cada comprobación. No se deben presentar como terminados los pasos que sigan pendientes.

## Referencias oficiales

- [Microsoft Learn - Instalar WSL](https://learn.microsoft.com/windows/wsl/install)
- [Microsoft Learn - Comandos básicos de WSL](https://learn.microsoft.com/windows/wsl/basic-commands)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Eclipse Adoptium / Temurin](https://adoptium.net/)
- [Apache Maven - Instalación](https://maven.apache.org/install)
- [Node.js - Descargas](https://nodejs.org/en/download/)
- [Documentación de npm](https://docs.npmjs.com/)
- [Android Studio](https://developer.android.com/studio)
- [Android Emulator](https://developer.android.com/studio/run/emulator)
- [Documentación de Flutter](https://docs.flutter.dev/)
- [Documentación de Dart](https://dart.dev/guides)
- [Instalar Docker Desktop en Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Documentación de Git](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com/)
