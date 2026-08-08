/// Money helpers — amounts are stored as integer minor units (e.g. paisa).
abstract final class MoneyFormat {
  static const String defaultCurrencyCode = 'PKR';

  static String formatMinor(int minorUnits, String currencyCode) {
    final major = minorUnits / 100.0;
    final fixed = minorUnits % 100 == 0
        ? major.toStringAsFixed(0)
        : major.toStringAsFixed(2);
    final withSeparators = fixed.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$currencyCode $withSeparators';
  }

  /// Parses a user-entered major-unit string into minor units.
  /// Returns null if empty; throws [FormatException] if invalid.
  static int? parseMajorToMinor(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim().replaceAll(',', '');
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null) {
      throw const FormatException('Enter a valid amount');
    }
    return (value * 100).round();
  }

  static String majorStringFromMinor(int? minor) {
    if (minor == null) return '';
    if (minor % 100 == 0) return (minor ~/ 100).toString();
    return (minor / 100).toStringAsFixed(2);
  }
}
