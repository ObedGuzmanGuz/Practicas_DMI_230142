import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:cinemapedia_app/presentation/providers/settings/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CountryDrawer extends ConsumerWidget {
  const CountryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(selectedRegion);
    final colors = Theme.of(context).colorScheme;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.28),
                    colors.secondary.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/cinemapedia_eye.png',
                      width: 76,
                      height: 76,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cinemapedia',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.tagline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
              child: Text(
                strings.chooseCountry,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            for (final region in movieRegions)
              ListTile(
                dense: true,
                leading: Text(region.flag, style: const TextStyle(fontSize: 24)),
                title: Text(region.menuLabel),
                subtitle: Text(region.isoCode),
                trailing: selectedRegion.isoCode == region.isoCode
                    ? Icon(Icons.check_circle_rounded, color: colors.primary)
                    : null,
                selected: selectedRegion.isoCode == region.isoCode,
                selectedTileColor: colors.primary.withValues(alpha: 0.09),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () {
                  ref.read(selectedMovieRegionProvider.notifier).state = region;
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: 8),
            const Divider(indent: 18, endIndent: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Text(
                strings.appearance,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            SwitchListTile.adaptive(
              value: isDark,
              secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: Text(isDark ? strings.darkMode : strings.lightMode),
              onChanged: (value) => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/favorites');
                },
                icon: const Icon(Icons.favorite_rounded),
                label: Text(strings.favorites),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
