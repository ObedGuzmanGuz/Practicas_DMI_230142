import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/content_mode_provider.dart';
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
    final contentMode = ref.watch(contentModeProvider);

    return Drawer(
      width: 330,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(gradient: LinearGradient(
                colors: [colors.primary.withValues(alpha: 0.30), colors.secondary.withValues(alpha: 0.13)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              )),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                    boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.22), blurRadius: 20)]),
                  child: ClipRRect(borderRadius: BorderRadius.circular(17),
                    child: Image.asset('assets/images/cinemapedia_eye.png', width: 70, height: 70)),
                ),
                const SizedBox(height: 12),
                Text('Cinemapedia', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.6)),
                const SizedBox(height: 4),
                Text(strings.tagline, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic)),
              ]),
            ),
            _SectionTitle(title: strings.settings),
            _SectionTitle(title: strings.content, icon: Icons.video_library_rounded),
            RadioListTile<ContentMode>(
              value: ContentMode.movies, groupValue: contentMode,
              title: Text(strings.movies), secondary: const Icon(Icons.movie_filter_rounded),
              onChanged: (value) { if (value != null) ref.read(contentModeProvider.notifier).setMode(value); },
            ),
            RadioListTile<ContentMode>(
              value: ContentMode.series, groupValue: contentMode,
              title: Text(strings.series), secondary: const Icon(Icons.live_tv_rounded),
              onChanged: (value) { if (value != null) ref.read(contentModeProvider.notifier).setMode(value); },
            ),
            const Divider(indent: 18, endIndent: 18),
            _SectionTitle(title: strings.chooseCountry, icon: Icons.language_rounded),
            for (final region in movieRegions)
              ListTile(
                dense: true,
                leading: Text(region.flag, style: const TextStyle(fontSize: 23)),
                title: Text(region.menuLabel),
                subtitle: Text(region.isoCode),
                trailing: selectedRegion.isoCode == region.isoCode
                    ? Icon(Icons.check_circle_rounded, color: colors.primary)
                    : null,
                selected: selectedRegion.isoCode == region.isoCode,
                selectedTileColor: colors.primary.withValues(alpha: 0.09),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                onTap: () => ref.read(selectedMovieRegionProvider.notifier).setRegion(region),
              ),
            const Divider(indent: 18, endIndent: 18),
            _SectionTitle(title: strings.appearance, icon: Icons.palette_rounded),
            SwitchListTile.adaptive(
              value: isDark,
              secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: Text(isDark ? strings.darkMode : strings.lightMode),
              onChanged: (value) => ref.read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
            const Divider(indent: 18, endIndent: 18),
            ListTile(
              leading: Icon(Icons.home_rounded, color: colors.primary),
              title: Text(strings.home),
              onTap: () { Navigator.pop(context); context.go('/'); },
            ),
            ListTile(
              leading: Icon(Icons.local_fire_department_rounded, color: colors.primary),
              title: Text(strings.popular),
              onTap: () { Navigator.pop(context); context.go('/popular'); },
            ),
            ListTile(
              leading: Icon(Icons.grid_view_rounded, color: colors.primary),
              title: Text(strings.categories),
              onTap: () { Navigator.pop(context); context.go('/categories'); },
            ),
            ListTile(
              leading: Icon(Icons.favorite_rounded, color: colors.primary),
              title: Text(strings.favorites),
              onTap: () { Navigator.pop(context); context.go('/favorites'); },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionTitle({required this.title, this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 5),
    child: Row(children: [
      if (icon != null) ...[Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8)],
      Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
    ]),
  );
}
