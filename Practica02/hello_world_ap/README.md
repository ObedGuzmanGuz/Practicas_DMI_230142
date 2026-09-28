# Práctica: Contador con funciones, colores y tipografía personalizada en Flutter

## Descripción

Esta práctica consiste en una aplicación desarrollada con **Flutter y Dart** que permite manipular un contador mediante botones para **incrementar, disminuir y reiniciar** su valor.  
También se agregaron cambios visuales para identificar fácilmente si el número mostrado es positivo, negativo o cero.

## Objetivo

Aplicar el manejo de estado en Flutter mediante `StatefulWidget` y `setState()`, además de personalizar la interfaz utilizando colores condicionales, botones reutilizables y una tipografía personalizada.

## ¿Qué se realizó?

- Se implementó un contador iniciado en `0`.
- Se agregó un botón **+1** para incrementar el contador.
- Se agregó un botón **-1** para disminuir el contador.
- Se agregó la opción de **reiniciar el contador a 0**.
- Se configuró el color del número según su valor:
  - **Verde:** número positivo.
  - **Rojo:** número negativo.
  - **Azul:** valor igual a cero.
- Se utilizó `setState()` para actualizar la interfaz cada vez que cambia el contador.
- Se creó el widget reutilizable `CustomButton` para los botones flotantes.
- Se configuró el texto `Click` / `Clicks` dependiendo del valor del contador.
- Se agregó la tipografía personalizada **Architext** mediante `pubspec.yaml`.
- Se aplicó un tema basado en color verde con `ThemeData`.

## Archivos principales modificados

- `lib/main.dart`  
  Configuración principal de la aplicación, tema, fuente Architext y pantalla inicial.

- `lib/presentation/screens/counter/counter_functions_screen.dart`  
  Contiene la lógica del contador, botones, colores condicionales y actualización del estado.

- `pubspec.yaml`  
  Registro de la tipografía personalizada utilizada en la aplicación.

## Evidencias

### 1. Contador con valor negativo

El valor se muestra en **rojo** cuando el contador es menor que cero.

![Contador negativo](evidencias/contador_negativo.png)

### 2. Contador en cero

Cuando el contador tiene un valor de `0`, se muestra en **azul**.

![Contador en cero](evidencias/contador_cero.png)

### 3. Contador con valor positivo

El valor se muestra en **verde** cuando el contador es mayor que cero.

![Contador positivo](evidencias/contador_positivo.png)

## Arquitectura

[Ver el HTML de la arquitectura interactiva](https://obedguzmanguz.github.io/Practicas_DMI_230142/Practica02/hello_world_ap/arquitectura/arquitectura_contador_flutter.html).
Para consultarlo localmente, abre ese archivo en el navegador con doble clic; no requiere Flutter.

El dibujo se generó y validó con **Archify** a partir del código real. Incluye un visor
integrado en español con detalles de archivos, las seis plataformas, conexiones,
zoom y navegación por teclado. La aplicación está en `Practica02/hello_world_ap`,
aunque la rama de trabajo sea `Practica03`.

La [ruta prevista para GitHub Pages](https://obedguzmanguz.github.io/Practicas_DMI_230142/Practica02/hello_world_ap/arquitectura/arquitectura_contador_flutter.html)
corresponde a publicar desde la raíz del repositorio; su disponibilidad depende de
la fusión y publicación que realice el propietario. No se desplegó en esta tarea.

Después de fusionar con `main`, cambia únicamente `CONFIG.codeRef` a `"main"` dentro
del HTML y publica esa documentación actualizada. GitHub Pages no cambia las
referencias de código automáticamente. Si cambia el código, actualiza también los
rangos de líneas y fragmentos.

Consulta [las fuentes, el mantenimiento y la validación](arquitectura/README.md).

## Tecnologías utilizadas

- Flutter
- Dart
- Material Design
- Architext
- Archify

## Resultado

La aplicación permite modificar el contador correctamente y muestra de forma visual su estado mediante colores y una tipografía personalizada, cumpliendo con los requisitos establecidos para la práctica.
