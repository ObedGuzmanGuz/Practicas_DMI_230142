# Práctica: Publicación de la App en Appetize.io

## 1. Descripción

En esta práctica se realiza el proceso de compilación, publicación y validación de **TokTik Azul**, una aplicación móvil desarrollada con Flutter que simula una red social de videos cortos.

Se utiliza Appetize.io para ejecutar la aplicación en dispositivos Android virtuales desde un navegador web, comprobar sus funcionalidades y compartir un enlace para su demostración.

La publicación realizada corresponde a un entorno de pruebas y demostración, no a una distribución comercial en Google Play Store.

## 2. Objetivo

Implementar el proceso de distribución y evaluación de TokTik Azul mediante Appetize.io, generando un APK de Android, validando su funcionamiento en dos configuraciones de dispositivos virtuales y documentando los resultados en GitHub.

## 3. Investigación de Appetize.io

Appetize.io es una plataforma que permite ejecutar aplicaciones móviles mediante dispositivos virtuales accesibles desde un navegador.

Sus principales características son:

- Ejecución de aplicaciones Android en un entorno virtual.
- Carga de aplicaciones mediante archivos APK.
- Compartición de enlaces para demostraciones y pruebas.
- Selección de dispositivos y versiones de sistema operativo disponibles.
- Herramientas para guardar capturas y revisar registros de depuración.
- Validación de interfaces y funcionalidades sin necesidad de instalar la aplicación en un teléfono físico.

**Plataforma:** https://appetize.io/

## 4. Revisión del proyecto Flutter

Antes de generar el APK, se revisó la estructura del proyecto, las dependencias, los recursos gráficos, los permisos y la configuración de Android.

Se utilizaron los siguientes comandos:

```bash
flutter doctor -v
flutter --version
flutter clean
flutter pub get
flutter analyze
```

Estos comandos permiten revisar el entorno de desarrollo, limpiar los archivos de compilaciones anteriores, descargar las dependencias y analizar el código fuente.

Las funcionalidades principales que se revisaron fueron la navegación entre secciones, la reproducción y el desplazamiento de videos, la selección de temas y la reproducción de sonidos.

## 5. Configuración y compilación

Para generar la versión de distribución se ejecutó:

```bash
flutter build apk --release
```


### Información de la compilación

- **Nombre del archivo:** `app-release.apk`
- **Versión de la aplicación:** [indicar versión]
- **Número de compilación:** [indicar número]
- **Tamaño del archivo:** [indicar tamaño obtenido]
- **Fecha de compilación:** [indicar fecha]

La generación se consideró exitosa únicamente después de comprobar que el comando finalizó correctamente y que el archivo APK existía en la ubicación indicada.

### Evidencia de compilación

![Resultado de flutter doctor](/Practica04/docs/apetize/evidencias/01_flutter-doctor.png)

![Análisis del proyecto](/Practica04/docs/apetize/evidencias/02_flutter-analyze.png)

![Compilación release del APK](/Practica04/docs/apetize/evidencias/03_compilacion-apk.png)

![Archivo APK generado y su tamaño](/Practica04/docs/apetize/evidencias/04_datos-apk.png)

## 6. Publicación en Appetize.io

Una vez generado el archivo APK, se accedió a Appetize.io y se inició sesión en la cuenta correspondiente.

Se cargó el archivo `app-release.apk` y se esperó a que terminara el procesamiento. Después se abrió la aplicación desde el panel para comprobar que estuviera disponible para su ejecución virtual.




![Aplicación cargada en Appetize](/Practica04/docs/apetize/evidencias/05_appetize-carga.png)

![Pantalla inicial de TokTik Azul en Appetize](/Practica04/docs/apetize/evidencias/06_appetize-inicio.png)

## 7. Configuración del entorno de prueba

Para evaluar la aplicación se utilizaron dos configuraciones de dispositivos Android virtuales disponibles en Appetize.

| Característica | Dispositivo 1 | Dispositivo 2 |
|---|---|---|
| Modelo | Pixel 7 | Pixel 11 pro |
| Versión de Android | N/A | N/A |
| Orientación | Vertical | Vertical |
| Plataforma | Appetize.io | Appetize.io |

Se mantuvo la orientación vertical para comprobar el comportamiento de la aplicación durante la navegación por los videos.

## 8. Pruebas funcionales

Las pruebas se realizaron con el propósito de verificar la carga inicial de la aplicación, la interacción con sus componentes y la adaptación de la interfaz a diferentes dispositivos.

| Prueba | Dispositivo 1 | Dispositivo 2 |
|---|---|---|
| Inicio de la aplicación | Exito | Exito |
| Navegación entre secciones | Exito |Exito |
| Desplazamiento vertical | Exito | Exito |
| Reproducción de videos | Exito | Exito |
| Consumo de contenido externo | Exito |Exito |
| Selección de temas | Exito | Exito |
| Reproducción de sonidos | Exito| Exito |
| Adaptabilidad de la interfaz |Exito | Exito|

Los resultados se registraron después de ejecutar cada prueba. Las funcionalidades que presentaron errores se identificaron como incidencias y se documentaron para su posterior corrección.

### Evidencias del dispositivo 1

![Pruebas de navegación del dispositivo 1](/Practica04/docs/apetize/evidencias/07_dispositivo1-pruebas.png)

![Pruebas de temas del dispositivo 1](/Practica04/docs/apetize/evidencias/08_dispositivo1-temas.png)

### Evidencias del dispositivo 2

![Pruebas de navegación del dispositivo 2](/Practica04/docs/apetize/evidencias/09_dispositivo2-pruebas.png)

![Pruebas de temas del dispositivo 2](/Practica04/docs/apetize/evidencias/10_dispositivo2-temas.png)

### Validación de YouTube

Se comprobó el comportamiento del reproductor integrado de YouTube desde la aplicación publicada.

Sin embargo YouTube no dejo cargar correctamente los videos

![Evidencia de la prueba de YouTube](/Practica04/docs/apetize/evidencias/11_youtube-validacion.png)

## 9. Incidencias y correcciones

Durante el desarrollo y las pruebas se identificaron aspectos relacionados con la reproducción de videos externos, la actualización de los iconos de los temas y la detección automática de las fechas del dispositivo.

| Incidencia | Acción realizada | Resultado |
|---|---|---|
| Reproducción de YouTube | Se revisó la configuración del reproductor integrado y su URL de origen. | Problemas para las reproduccion de videos |
| Actualización del icono al cambiar de tema | Se revisó el mecanismo nativo de Android encargado de cambiar el icono. | Se cargo correctamente |
| Actualización automática según la fecha | Se revisó la sincronización del tema automático con la fecha del dispositivo. |Se cargo correctamente |

Las correcciones se consideraron validadas solamente después de repetir las pruebas en la compilación actualizada.

## 10. Enlace compartido

Después de publicar la compilación, se obtuvo el enlace de acceso desde la opción de compartir de Appetize.

Se abrió el enlace en una sesión independiente del navegador para comprobar que permitiera acceder a la aplicación.

**Enlace de demostración:** [https://appetize.io/app/b_slelkxqflz3axhvllgvx4uacdi]

![Prueba del enlace compartido](/Practica04/docs/apetize/evidencias/12_enlace-compartido.png)

## 11. Resultados obtenidos

- Se generó el APK de distribución de TokTik Azul.
- Se publicó la aplicación en Appetize.io.
- Se realizaron pruebas en dos configuraciones de dispositivos Android virtuales.
- Se documentaron las funcionalidades verificadas y las incidencias encontradas.
- Se obtuvo un enlace para la demostración de la aplicación.
- Se registraron las evidencias y los cambios de documentación en GitHub.

Los resultados específicos de cada prueba se encuentran descritos en las tablas anteriores y respaldados por las capturas correspondientes.

## 13. Conclusión

La práctica permitió conocer el proceso de compilación de una aplicación desarrollada con Flutter, su publicación en un entorno virtual y la evaluación de su funcionamiento desde un navegador web.

Appetize.io facilita la demostración de aplicaciones y permite probar sus interfaces en diferentes dispositivos virtuales sin requerir su instalación física. Sin embargo, las funciones que dependen de servicios externos, las características específicas de Android y ciertos comportamientos del dispositivo deben verificarse durante las pruebas, ya que pueden presentar diferencias con respecto a un teléfono real.

La documentación en GitHub permite conservar las evidencias técnicas, registrar las incidencias encontradas y mantener un historial de los cambios realizados en el proyecto.
