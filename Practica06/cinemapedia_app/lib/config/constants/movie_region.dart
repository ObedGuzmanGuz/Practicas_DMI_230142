import 'package:flutter/material.dart';

/// País utilizado para solicitar los datos localizados a TMDB.
class MovieRegion {
  final String isoCode;
  final String languageCode;
  final String countryName;
  final String languageName;
  final String flag;
  final Locale locale;

  const MovieRegion({
    required this.isoCode,
    required this.languageCode,
    required this.countryName,
    required this.languageName,
    required this.flag,
    required this.locale,
  });

  String get menuLabel => '$countryName ($languageName)';
  String get shortLabel => '$isoCode ($languageName)';
}

/// Se incluyen los cuatro países escritos en las indicaciones.
/// México y Estados Unidos pertenecen al mismo continente; Japón y Alemania
/// agregan Asia y Europa, respectivamente.
const movieRegions = <MovieRegion>[
  MovieRegion(
    isoCode: 'MX',
    languageCode: 'es-MX',
    countryName: 'México',
    languageName: 'Español',
    flag: '🇲🇽',
    locale: Locale('es', 'MX'),
  ),
  MovieRegion(
    isoCode: 'US',
    languageCode: 'en-US',
    countryName: 'Estados Unidos',
    languageName: 'English',
    flag: '🇺🇸',
    locale: Locale('en', 'US'),
  ),
  MovieRegion(
    isoCode: 'JP',
    languageCode: 'ja-JP',
    countryName: 'Japón',
    languageName: '日本語',
    flag: '🇯🇵',
    locale: Locale('ja', 'JP'),
  ),
  MovieRegion(
    isoCode: 'DE',
    languageCode: 'de-DE',
    countryName: 'Alemania',
    languageName: 'Deutsch',
    flag: '🇩🇪',
    locale: Locale('de', 'DE'),
  ),
];
