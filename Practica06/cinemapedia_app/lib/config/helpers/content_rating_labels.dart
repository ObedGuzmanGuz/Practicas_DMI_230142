class ContentRatingLabels {
  ContentRatingLabels._();

  static String _normalize(String value) => value.trim().toUpperCase().replaceAll(' ', '').replaceAll('B-15', 'B15').replaceAll('PG13', 'PG-13');

  static String compact(String value, String countryCode) {
    final code = _normalize(value);
    if (code.isEmpty) return 'NR';
    final age = _age(code, countryCode.toUpperCase());
    return age == null ? code : '$code · $age';
  }

  static String detail(String value, String countryCode) {
    final code = _normalize(value);
    if (code.isEmpty) return 'NR · Sin clasificación disponible';
    final meaning = _meaning(code, countryCode.toUpperCase());
    return meaning == null ? code : '$code · $meaning';
  }

  static String? _age(String code, String country) {
    const tvAges = {'TV-Y': 'Infantil', 'TV-Y7': '7+', 'TV-G': 'Todo público', 'TV-PG': 'Guía', 'TV-14': '14+', 'TV-MA': '17+'};
    if (code.startsWith('TV-')) return tvAges[code];
    if (country == 'MX') {
      const ages = {
        'AA': '0–6', 'A': 'Todo público', 'B': '12+',
        'B15': '15+', 'C': '18+', 'D': '18+',
      };
      return ages[code];
    }
    if (country == 'US') {
      const ages = {'G': 'Todo público', 'PG': 'Guía', 'PG-13': '13+', 'R': '17+', 'NC-17': '18+'};
      return ages[code];
    }
    if (country == 'DE') {
      final fsk = code.replaceFirst('FSK', '');
      if (['0', '6', '12', '16', '18'].contains(fsk)) return '$fsk+';
    }
    if (country == 'JP') {
      const ages = {'G': 'Todo público', 'PG12': '12+', 'R15+': '15+', 'R18+': '18+'};
      return ages[code];
    }
    if (country == 'CN') {
      const ages = {'0': 'Todo público', '6': '6+', '8': '8+', '12': '12+', '15': '15+', '18': '18+'};
      return ages[code];
    }
    if (country == 'SA') {
      const ages = {'G': 'Todo público', 'PG': 'Guía', 'PG12': '12+', 'PG15': '15+', 'R15': '15+', 'R18': '18+'};
      return ages[code];
    }
    return tvAges[code];
  }

  static String? _meaning(String code, String country) {
    const tvMeanings = {
      'TV-Y': 'dirigida a público infantil', 'TV-Y7': 'dirigida a mayores de 7 años',
      'TV-G': 'apta para todo público', 'TV-PG': 'se recomienda orientación parental',
      'TV-14': 'puede no ser apta para menores de 14 años', 'TV-MA': 'dirigida a público adulto',
    };
    if (code.startsWith('TV-')) return tvMeanings[code];
    if (country == 'MX') {
      const meanings = {
        'AA': 'para todo público con atractivo infantil, comprensible para menores de 7 años',
        'A': 'apta para todo público',
        'B': 'para adolescentes de 12 años en adelante',
        'B15': 'para mayores de 15 años',
        'C': 'para personas adultas de 18 años en adelante',
        'D': 'contenido adulto; consulta las advertencias de contenido',
      };
      return meanings[code];
    }
    if (country == 'US') {
      const meanings = {
        'G': 'apta para todas las edades', 'PG': 'se recomienda orientación parental',
        'PG-13': 'parte del contenido puede no ser apto para menores de 13',
        'R': 'menores de 17 requieren acompañamiento adulto',
        'NC-17': 'no apta para menores de 17 años',
      };
      return meanings[code];
    }
    if (country == 'DE') {
      final fsk = code.replaceFirst('FSK', '');
      const meanings = {'0': 'sin restricción de edad', '6': 'a partir de 6 años', '12': 'a partir de 12 años', '16': 'a partir de 16 años', '18': 'solo adultos'};
      return meanings[fsk];
    }
    if (country == 'JP') {
      const meanings = {'G': 'apta para todas las edades', 'PG12': 'se recomienda orientación para menores de 12', 'R15+': 'restringida a mayores de 15 años', 'R18+': 'restringida a mayores de 18 años'};
      return meanings[code];
    }
    final age = _age(code, country);
    return age == null ? null : (age == 'Todo público' || age == 'Infantil' || age == 'Guía' ? age : 'recomendada para $age');
  }
}
