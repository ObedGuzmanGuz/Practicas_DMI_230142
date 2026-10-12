import 'package:intl/intl.dart';

class HumanFormats {
  static String humanReadableNumber(num value) =>
      NumberFormat.compact(locale: 'es').format(value);
}
