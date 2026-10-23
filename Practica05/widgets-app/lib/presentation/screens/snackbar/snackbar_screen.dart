import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SnackbarScreen extends StatelessWidget {
  static const name = 'snackbar_screen';
  const SnackbarScreen({super.key});

  void showCustomSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackbar = SnackBar(
      content: const Text('¡Todo listo! El aviso se muestra correctamente.'),
      action: SnackBarAction(label: 'Entendido', onPressed: () {}),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¿Deseas continuar?'),
        content: const Text('Esta ventana demuestra cómo solicitar confirmación antes de continuar con una acción.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => context.pop(), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avisos y diálogos')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 54),
              const SizedBox(height: 14),
              const Text('Prueba las formas de mostrar información en pantalla.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Acerca de la aplicación'),
                      content: const Text('Laboratorio Digital reúne ejemplos educativos de botones, tarjetas, controles y animaciones en Flutter. Versión 1.0.'),
                      actions: [
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                label: const Text('Acerca de la aplicación'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: () => openDialog(context),
                label: const Text('Mostrar diálogo'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Mostrar aviso'),
        icon: const Icon(Icons.campaign_rounded),
        onPressed: () => showCustomSnackbar(context),
      ),
    );
  }
}
