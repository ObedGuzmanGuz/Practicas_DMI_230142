# Arquitectura interactiva de Yes No App

Entrega principal: [arquitectura_yes_no_app.html](arquitectura_yes_no_app.html).
Abre el archivo con doble clic en Chrome, Edge u otro navegador moderno.
Contiene SVG, estilos, datos, fragmentos y JavaScript integrados; no necesita
servidor, Flutter, dependencias de red ni archivos adicionales para consultarlo.
Los enlaces a GitHub y servicios solo se abren cuando el lector los selecciona.

## Navegación

- Clic, Enter o espacio sobre cualquiera de los 24 bloques: abre sus detalles
  y resalta el componente y sus conexiones.
- Tab recorre los controles y bloques. Escape o Cerrar cierra el panel y devuelve
  el foco. El panel mantiene el foco dentro y dispone de desplazamiento interno.
- Arrastra el fondo o usa las flechas con el lienzo enfocado para desplazarte.
- Rueda, `+` y `−`: acercamiento. Ajustar a pantalla o `0`: encuadra todo.
  Restablecer también elimina la selección. El foco trae los bloques a la vista.
- En una pantalla estrecha, usa el acercamiento o el selector «Ir a un bloque».

Las conexiones cian indican composición o dependencia; las verdes discontinuas,
ejecución o notificación; las violetas punteadas, documentación. Las plataformas
integran el mismo código Dart y no se llaman entre sí. Los servicios de Internet
están fuera del límite de la aplicación. Las agrupaciones no pretenden describir
una implementación completa de Clean Architecture.

## Flujo comprobado en los diez archivos Dart

1. `main()` llama `runApp(const MyApp())`. `MultiProvider` y
   `ChangeNotifierProvider` registran `ChatProvider`; `MaterialApp` usa
   `AppTheme(selectedColor: 0).theme()` y muestra `ChatScreen`.
2. `MessageFieldBox` recorta espacios, descarta texto vacío, limpia el campo,
   devuelve el foco y llama a `onValue`, conectado a `sendMessage`.
3. El provider crea `Message`, lo incorpora a `messageList`, notifica y mueve
   el scroll. `_ChatView` observa con `context.watch<ChatProvider>()` y elige
   `MyMessageBubble` o `HerMessageBubble` mediante `message.fromWho`.
4. El estado comienza en `sent`; tras 400 ms pasa a `delivered`; después de
   otros 700 ms pasa a `read`. Son **simulaciones locales**, no confirmaciones
   de un servidor ni de otra persona. Las palomitas usan `done` o `done_all`;
   `read` se pinta azul claro.
5. Solo después de esa secuencia, si el texto limpio termina en `?`, se ejecuta
   `herReply()`. Sin ese carácter final, el flujo acaba sin respuesta ni API.
6. `GetYesNoAnswer` elige localmente con `Random.nextInt(100)`: 0–39 = Sí,
   40–79 = No, 80–99 = Tal vez. Son probabilidades de 40 %, 40 % y 20 % por
   elección; no cuotas de una secuencia corta ni análisis de la pregunta por IA.
7. Dio solicita `GET https://yesno.wtf/api` con `force: answer`. **No envía
   el texto de la pregunta.** Comprueba `data != null`, respuesta coincidente
   e imagen de tipo `String`. Con datos válidos conserva la URL de imagen.
8. Construye `YesNoModel` directamente y llama `toMessageEntity()`: traduce el
   texto, fija `FromWho.hers` y convierte una imagen vacía en `imageUrl: null`.
   `fromJsonMap()` y `toJson()` existen, pero no participan en este recorrido.
9. `herReply()` incorpora el `Message` y notifica. La burbuja muestra texto,
   hora y, si existe URL, solicita el GIF mediante **otra descarga**,
   `Image.network`. El avatar es otro recurso externo, `NetworkImage` desde
   `tse3.mm.bing.net`; no es autenticación ni una identidad real.

Ante `DioException` o datos que no satisfagan las comprobaciones, se conserva
el texto elegido sin GIF. `connectTimeout` y `receiveTimeout` valen 10 segundos
**cada uno**, no un único límite global. Si falla la descarga posterior de la
imagen, `errorBuilder` muestra «No se pudo cargar el GIF».

`messageList` permanece en memoria e inicia con dos mensajes locales ya leídos.
No se observa persistencia. `Message.formattedTime` convierte a hora local y
produce `HH:mm`. El provider libera su `ScrollController` y el helper cierra Dio;
el campo libera `TextEditingController` y `FocusNode`. El tema de la aplicación
usa Material 3 y el rojo `Color.fromARGB(255, 202, 18, 18)` en el índice 0.
`Brightness.dark` está comentado: el diseño oscuro del visor es independiente.

## Fuentes y diferencias con el ZIP

La raíz Git se comprobó en `Practicas_DMI_230142`; la app está en
`Practica03/yes_no_app`, paquete `yes_no_app`. Rama actual: `Practica03`.
Remoto `origin`: `https://github.com/ObedGuzmanGuz/Practicas_DMI_230142.git`.
No se encontraron instrucciones `AGENTS.md` aplicables en los ancestros
revisados ni dentro de esta práctica. Se leyó el skill Archify y el visor previo
del contador para conservar su estilo e interacción; sus archivos se preservan.

El commit local y el árbol remoto consultado coinciden:
`db79eaa26568ed7526415a6b58bcb49fdca9521e`. Los archivos de trabajo tienen
cambios anteriores a esta tarea. De los 34 archivos enlazados, 32 coinciden con
sus blobs remotos; `pubspec.yaml` y `web/index.html` difieren. Sus enlaces se
marcan pendientes para el contenido local. La comparación usa hashes Git con
normalización de finales de línea, no la apertura individual de las páginas.

La discrepancia de splash del ZIP **ya no está presente en la copia actual**:
`image_dark` apunta a `web/icons/alien_ogf.png`, también dentro de `android_12`,
y ese recurso existe. No se modificó esa configuración ni se regeneró el splash.
Las herramientas de iconos y splash habilitan Android y Web y deshabilitan iOS;
su configuración no demuestra que los recursos generados funcionen correctamente.

| Paquete | Uso | Restricción en pubspec.yaml | Versión resuelta en pubspec.lock |
| --- | --- | --- | --- |
| provider | Ejecución | ^6.1.5+1 | 6.1.5+1 |
| dio | Ejecución | ^5.11.1 | 5.11.1 |
| cupertino_icons | Ejecución | ^1.0.8 | 1.0.9 |
| flutter_launcher_icons | Generación / desarrollo | ^0.14.4 | 0.14.4 |
| flutter_native_splash | Generación / desarrollo | ^2.4.8 | 2.4.8 |
| flutter_lints | Análisis / desarrollo | ^6.0.0 | 6.0.0 |
| flutter_test | Pruebas / desarrollo | SDK Flutter | SDK; 0.0.0 en el lock |

Flutter también procede del SDK. El `0.0.0` de un paquete SDK en el lock no
indica la versión instalada de Flutter. Las versiones de los paneles se extraen
de los archivos actuales al regenerar.

## Observaciones pendientes de la aplicación

- `test/widget_test.dart` conserva el test del contador: espera 0/1 y busca
  `Icons.add`. No acredita funcionamiento del chat y no se ejecutó.
- Los `testExample()` de iOS y macOS no contienen verificaciones funcionales.
- El AndroidManifest principal sí declara `android.permission.INTERNET`.
- Los dos entitlements de macOS no declaran
  `com.apple.security.network.client`; revisar al validar esa plataforma.
- Android, iOS, Web, Windows, Linux y macOS están presentes/configurados.
  No se probaron compilaciones, red ni ejecución Flutter en esos seis destinos.

## GitHub Pages y referencia del código

[URL prevista de la documentación — publicación no verificada](https://obedguzmanguz.github.io/Practicas_DMI_230142/Practica03/yes_no_app/arquitectura/arquitectura_yes_no_app.html).

Pages debe publicar la rama que contenga estos archivos y la carpeta `/(root)`.
El usuario realizará push, fusión y publicación. Si cambia la fuente a `main`,
los archivos deben estar fusionados allí. No se hizo un despliegue ni se afirmó
que la dirección prevista esté publicada. Publicar Flutter Web es otra tarea;
no se utilizó `web/index.html` ni `flutter build web` para esta arquitectura.

La única fuente editable de enlaces es [configuracion.json](configuracion.json):

```json
{
  "repoUrl": "https://github.com/ObedGuzmanGuz/Practicas_DMI_230142",
  "codeRef": "Practica03",
  "appPath": "Practica03/yes_no_app"
}
```

Después de fusionar, cambia **solo `codeRef` a `main`** en ese archivo y regenera
el HTML. Conserva `appPath` si no se movió la app. El generador integra la misma
configuración en `CONFIG`: no edites ambas copias. La rama que publica Pages y
`codeRef` son independientes; cambiar una no cambia la otra.

Los archivos usan `/blob/REFERENCIA/RUTA#Lx-Ly`; las carpetas usan `/tree/`.
Se codifican los componentes de URL y se respetan `Screens` e `infraestructure`.
Si el código cambia, revisa rangos y fragmentos. El árbol remoto guardado es una
instantánea de `Practica03`; cambiar `codeRef` no acredita coincidencia en `main`.

## Regeneración y evidencias

Desde la carpeta de la app:

```powershell
python arquitectura/generar.py
python arquitectura/verificar.py
```

El generador usa Python estándar y Git. El verificador de mantenimiento requiere
Chrome o Edge y `websocket-client`; no son dependencias de la app ni requisitos
para leer el HTML. Inicia un navegador sin ventana y un servidor efímero en
loopback para comprobar una subcarpeta equivalente a Pages; los cierra al terminar.
Si no encuentra el navegador, admite su ruta mediante la variable `CHROME_PATH`.
La comparación con `estado-inicial.json` corresponde a esta entrega; si en el
futuro cambias la aplicación, esa comprobación avisará de la diferencia para que
revises y documentes la nueva base, en lugar de declarar que sigue intacta.

| Archivo | Responsabilidad |
| --- | --- |
| `arquitectura_yes_no_app.html` | Entrega autónoma para abrir o publicar. |
| `configuracion.json` | Única fuente editable de repoUrl, codeRef, appPath y Pages. |
| `yes_no_app.archify.json` | Especificación base congelada, tipo architecture. |
| `generar.py` | Datos, extracción de fragmentos, enlaces e integración de geometría. |
| `visor.template.html` | Interfaz accesible en español; sin dependencias externas. |
| `verificar.py` | Revisión de fuentes, conservación y navegador. |
| `evidencia/archify_base.html` | Salida original intacta de Archify deliver. |
| `evidencia/archify-delivery.json` | Recibo determinista y hashes de la base entregada. |
| `evidencia/archify_base.visual-check.*` | Medidas, capturas y recibo del navegador base. |
| `evidencia/remoto.json` | Árbol Git de la rama consultada. |
| `evidencia/fuentes.json` | Hashes, rutas, líneas y coincidencia local/remota. |
| `evidencia/navegador-final.json` | Recibo del visor final con hash propio. |
| `evidencia/yes-no-*.png` | Capturas del visor y paneles en escritorio y móvil. |
| `evidencia/estado-inicial.json` | Hashes de archivos existentes antes de editar documentación. |
| `VALIDACION.md` | Alcance, resultados y recibos de entrega. |

Archify 2.17 se utilizó realmente: `validate` y `deliver`, perfil `showcase`,
nueve comprobaciones, cero errores y cero advertencias. Su interfaz nativa solo
admite inglés o chino; por ello la **base** conserva controles y `lang` en inglés.
El **HTML principal** usa un visor español propio con geometría principal de esa
base, ampliaciones y revisión independiente. No se modificó el skill instalado.
El recibo de Archify no se atribuye al HTML final modificado.

Si necesitas cambiar la topología base, crea una nueva versión de la
especificación y repite `validate`, `deliver` y `visual-check` mediante el CLI
instalado de Archify antes de integrar el HTML. No edites la base para aparentar
una validación. Las rutas adicionales del visor y sus textos se mantienen en
`generar.py`; tras cambiarlas, regenera y vuelve a verificar.
