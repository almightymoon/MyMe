import '../value_objects/money_minor.dart';

/// Money helpers — amounts are stored as [MoneyMinor] (arbitrary-precision
/// minor units, e.g. paisa). All formatting/parsing here is done with
/// [BigInt]/string math; the full minor-unit value is never routed through
/// `double`, so large amounts (e.g. PKR 150,000,000.00) never lose precision.
abstract final class MoneyFormat {
  static const String defaultCurrencyCode = 'PKR';

  static final RegExp _majorInputPattern = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$');
  static final RegExp _thousandsSeparator = RegExp(r'(\d)(?=(\d{3})+(?!\d))');

  /// Formats [minor] as `"CODE 1,234.56"`, splitting major/fraction via
  /// integer [BigInt] division/modulo instead of converting to `double`.
  static String formatMinor(MoneyMinor minor, String currencyCode) {
    return formatSignedMinor(minor.value, currencyCode);
  }

  /// Formats a signed minor-unit [BigInt] (e.g. net balance may be negative).
  static String formatSignedMinor(BigInt signedMinor, String currencyCode) {
    final negative = signedMinor.isNegative;
    final abs = signedMinor.abs();
    final major = abs ~/ BigInt.from(100);
    final fraction = abs % BigInt.from(100);
    final majorDigits = major.toString().replaceAllMapped(
      _thousandsSeparator,
      (match) => '${match[1]},',
    );
    final formatted = fraction == BigInt.zero
        ? majorDigits
        : '$majorDigits.${fraction.toString().padLeft(2, '0')}';
    final body = negative ? '-$formatted' : formatted;
    return '$currencyCode $body';
  }

  /// Parses a user-entered major-unit decimal string (optional single
  /// decimal point, up to 2 fraction digits) into [MoneyMinor] using
  /// [BigInt]/string math — never `double`.
  ///
  /// Returns `null` for empty/blank input; throws [FormatException] for
  /// malformed input (multiple decimal points, non-digit characters, more
  /// than 2 fraction digits, etc).
  static MoneyMinor? parseMajorToMinor(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim().replaceAll(',', '');
    if (trimmed.isEmpty) return null;
    if (!_majorInputPattern.hasMatch(trimmed)) {
      throw const FormatException('Enter a valid amount');
    }

    final dotIndex = trimmed.indexOf('.');
    final String integerPart;
    String fractionPart;
    if (dotIndex < 0) {
      integerPart = trimmed;
      fractionPart = '';
    } else {
      integerPart = trimmed.substring(0, dotIndex);
      fractionPart = trimmed.substring(dotIndex + 1);
    }
    fractionPart = fractionPart.padRight(2, '0');

    final minorDigits = '$integerPart$fractionPart';
    final value = BigInt.tryParse(minorDigits);
    if (value == null) {
      throw const FormatException('Enter a valid amount');
    }
    return MoneyMinor.fromBigInt(value);
  }

  /// Inverse of [parseMajorToMinor]: renders a major-unit decimal string
  /// suitable for editing in a text field (e.g. `"150000000.50"`).
  static String majorStringFromMinor(MoneyMinor? minor) {
    if (minor == null) return '';
    final major = minor.value ~/ BigInt.from(100);
    final fraction = minor.value % BigInt.from(100);
    if (fraction == BigInt.zero) return major.toString();
    return '$major.${fraction.toString().padLeft(2, '0')}';
  }
}
