import 'package:cinemapedia_app/config/constants/movie_region.dart';
import 'package:cinemapedia_app/config/l10n/app_strings.dart';
import 'package:cinemapedia_app/presentation/providers/settings/movie_region_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryDrawer extends ConsumerWidget {
  const CountryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRegion = ref.watch(selectedMovieRegionProvider);
    final strings = AppStrings(selectedRegion);
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
              color: colors.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public, size: 34, color: colors.onPrimaryContainer),
                  const SizedBox(height: 12),
                  Text(
                    strings.regionalCatalog,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.chooseCountry,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                strings.chooseCountry,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final region in movieRegions)
              ListTile(
                leading: Text(region.flag, style: const TextStyle(fontSize: 25)),
                title: Text(region.menuLabel),
                subtitle: Text(region.isoCode),
                trailing: selectedRegion.isoCode == region.isoCode
                    ? Icon(Icons.check_circle, color: colors.primary)
                    : null,
                selected: selectedRegion.isoCode == region.isoCode,
                onTap: () {
                  ref.read(selectedMovieRegionProvider.notifier).state = region;
                  Navigator.of(context).pop();
                },
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cinemapedia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
