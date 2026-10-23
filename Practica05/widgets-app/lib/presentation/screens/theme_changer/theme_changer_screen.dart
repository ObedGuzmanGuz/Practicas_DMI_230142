import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgets_app/config/theme/app_theme.dart';
import 'package:widgets_app/presentation/providers/theme_provider.dart';

class ThemeChangerScreen extends ConsumerWidget {
  static const name = 'theme_changer_screen';
  const ThemeChangerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkmode = ref.watch(themeNotifierProvider).isDarkmode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizar apariencia'),
        actions: [
          IconButton(
            tooltip: isDarkmode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            icon: Icon(isDarkmode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => ref.read(themeNotifierProvider.notifier).toggleDarkmode(),
          ),
        ],
      ),
      body: const _ThemeChangerView(),
    );
  }
}

class _ThemeChangerView extends ConsumerWidget {
  const _ThemeChangerView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorListProvider);
    final selectedColor = ref.watch(themeNotifierProvider).selectedColor;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Elige un color de acento',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text('El fondo permanece oscuro; el color elegido resalta botones e iconos.'),
        const SizedBox(height: 12),
        ...List.generate(colors.length, (index) {
          final color = colors[index];
          return Card(
            color: theme.brightness == Brightness.dark ? const Color(0xFF111111) : null,
            child: RadioListTile<int>(
              title: Text(colorNameList[index], style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              subtitle: Text('#${color.value.toRadixString(16).substring(2).toUpperCase()}'),
              secondary: CircleAvatar(backgroundColor: color, radius: 13),
              activeColor: color,
              value: index,
              groupValue: selectedColor,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeNotifierProvider.notifier).changeColorIndex(value);
                }
              },
            ),
          );
        }),
      ],
    );
  }
}
