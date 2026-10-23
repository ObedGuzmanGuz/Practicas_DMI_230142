import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  static const name = 'progress_screen';
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicadores de progreso')),
      body: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Carga continua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Este indicador gira mientras una tarea sigue en proceso.'),
              const SizedBox(height: 18),
              Center(child: CircularProgressIndicator(strokeWidth: 3, color: colors.primary, backgroundColor: colors.primary.withValues(alpha: 0.14))),
              const SizedBox(height: 34),
              const Text('Progreso animado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('La barra se llena y vuelve a empezar para mostrar una carga en movimiento.'),
              const SizedBox(height: 18),
              const _ControlledProgresIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlledProgresIndicator extends StatefulWidget {
  const _ControlledProgresIndicator();

  @override
  State<_ControlledProgresIndicator> createState() => _ControlledProgresIndicatorState();
}

class _ControlledProgresIndicatorState extends State<_ControlledProgresIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final value = _progress.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4,
                    color: colors.primary,
                    backgroundColor: colors.primary.withValues(alpha: 0.14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 13,
                      color: colors.primary,
                      backgroundColor: colors.primary.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(value * 100).round()} % completado',
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}
