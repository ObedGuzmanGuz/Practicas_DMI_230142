# Arquitectura interactiva del contador

Abre [arquitectura_contador_flutter.html](arquitectura_contador_flutter.html) con
doble clic en un navegador moderno. El archivo contiene SVG, estilos, datos y
JavaScript; funciona sin Flutter, sin backend y sin descargar recursos.

El repositorio revisado es `ObedGuzmanGuz/Practicas_DMI_230142`, rama `Practica03`.
La ubicación obtenida de la estructura local es **`APP_ROOT = Practica02/hello_world_ap`**.
El commit local y el remoto revisados coinciden:
`0aee0ac068b8f9c7bf7e6930b594695326666bd5`.

## Contenido y navegación

Hay 19 bloques seleccionables, incluidos Android, Windows, Linux, macOS, iOS y Web.
Las plataformas comparten una conexión de integración con Flutter; no representan
servicios independientes. Cada una abre sus dos archivos de configuración reales.

El arranque representado es `main() → runApp(MyApp()) → MyApp / MaterialApp →
CounterFunctionsScreen`. Las líneas cian representan estructura o configuración;
las verdes discontinuas representan eventos y reconstrucción. `CounterScreen`
está aislada y tiene borde discontinuo porque su import está comentado.

Los detalles explican `CustomButton`, los dos reinicios, `clickCounter`, `setState()`,
la reconstrucción de `Text`, los colores y la condición `Click` / `Clicks`.
La familia **Architext** y el archivo **assets/fonts/Architex.ttf** conservan sus
nombres exactos. Los fragmentos se extraen del código actual al generar el HTML.

- Clic, Enter o espacio: abrir detalles del bloque.
- Tab: recorrer bloques y controles. Escape o Cerrar: cerrar y devolver el foco.
- Arrastrar el fondo o usar flechas con el lienzo enfocado: desplazar.
- Botones + / − o rueda: acercar y alejar.
- Ajustar a pantalla o tecla 0: encuadrar todos los componentes.
- Restablecer vista: encuadrar y quitar la selección.

Los paneles conservan el espacio del diagrama, tienen desplazamiento interno y
mantienen el foco dentro mientras están abiertos. En móvil conviene acercar el
lienzo para leer tarjetas; los paneles usan casi toda la pantalla.

## GitHub y publicación posterior

Todos los enlaces se construyen en el HTML desde `CONFIG.repository`,
`CONFIG.codeRef`, `CONFIG.appRoot` y las rutas de `DATA`. No contienen rutas Windows.
Las rutas de archivos parten de la raíz del repositorio; los archivos usan `blob`,
las carpetas `tree`, y los archivos de texto incluyen líneas obtenidas localmente.
El recurso binario de la fuente no tiene líneas.

Tras fusionar con `main`, cambia **solo `CONFIG.codeRef` a `"main"`** en el HTML
terminado y publica esa versión actualizada. El generador conserva esta opción si
el HTML ya existe. No hace falta editar cada enlace ni la especificación Archify.
GitHub Pages no cambia automáticamente la referencia de los enlaces de código.

Si Pages publica desde la raíz de este repositorio, la ruta prevista es:

[Arquitectura en GitHub Pages](https://obedguzmanguz.github.io/Practicas_DMI_230142/Practica02/hello_world_ap/arquitectura/arquitectura_contador_flutter.html).

La ruta queda documentada para tu publicación posterior. No se efectuó ningún
commit, push, merge ni despliegue, ni se comprobó una publicación de este HTML.
Si cambian el código o su ubicación, actualiza rutas, rangos, fragmentos y evidencia;
el cambio de referencia por sí solo no actualiza esos datos.

## Uso real de Archify

Se utilizó el skill Archify instalado, versión declarada 2.17, y su CLI para
validar y entregar [la especificación](contador.archify.json) de tipo `architecture`.
El [HTML base](evidencia/archify_base.html) es la salida intacta de `deliver`.

El visor estándar de esa versión solo localiza controles en inglés o chino, por lo
que su HTML base conserva la interfaz y `lang` en inglés. El **HTML final enlazado
arriba** integra las rutas SVG verificadas de Archify en un visor propio completamente
en español, con tarjetas ampliadas, seis plataformas individuales, tipografía y
detalles del código. No se modificó el paquete instalado de Archify.

Esta distinción es deliberada: el recibo de Archify corresponde al HTML base;
la comprobación del visor final tiene su propio recibo y hash. La salida final no
se presenta como si hubiera pasado sin modificaciones por el validador de Archify.

## Archivos de documentación

| Archivo | Función |
| --- | --- |
| `arquitectura_contador_flutter.html` | Entrega autónoma para abrir o publicar. |
| `contador.archify.json` | Especificación congelada aceptada por Archify. |
| `visor.template.html` | Plantilla del visor en español; no es la entrega para abrir. |
| `generar.py` | Integra la geometría base, lee el código y obtiene líneas y rutas. |
| `verificar.py` | Comprueba el HTML final mediante Chrome y DevTools; no ejecuta Flutter. |
| `evidencia/archify_base.html` | Salida original de Archify conservada para trazabilidad. |
| `evidencia/archify_base.visual-check.*` | Recibo y capturas del navegador de Archify. |
| `evidencia/remoto.json` | Árbol Git obtenido de GitHub para la referencia revisada. |
| `evidencia/fuentes.json` | Hashes, rutas, líneas y coincidencia local/remota. |
| `evidencia/navegador-final.json` | Resultado de las 100 comprobaciones del HTML final. |
| `evidencia/contador-*.png` | Capturas del HTML final en escritorio y móvil. |
| `VALIDACION.md` | Alcance y resultados de la revisión. |

Fuera de esta carpeta se actualizó únicamente la sección Arquitectura del README
de la aplicación. El HTML anterior estaba marcado como eliminado al empezar y se
regeneró en su ubicación original. Se conservó el ZIP sin seguimiento encontrado.

## Regenerar la documentación

Para cambios de texto o detalles del visor, desde APP_ROOT:

```powershell
python arquitectura/generar.py
python arquitectura/verificar.py
```

El generador utiliza Python estándar y Git. El verificador requiere Chrome o Edge
y el paquete Python `websocket-client`; estos requisitos son solo para mantenimiento,
no para consultar el HTML. El verificador inicia un navegador sin ventana y un
servidor temporal en loopback para simular la subcarpeta de Pages, y los cierra al
terminar. No agrega dependencias a Flutter.

Si cambias la topología, genera una nueva especificación y repite `validate` y
`deliver` del skill antes de integrar su nuevo HTML base. No edites el recibo ni la
salida congelada para aparentar una validación. Si el remoto cambia, vuelve a
consultar su árbol Git antes de regenerar; `remoto.json` es una instantánea, no una
consulta en vivo. Revisa finalmente las capturas y actualiza `VALIDACION.md`.
