/// Precision-safe money value object for monetary fields (Goals, Finance, …).
///
/// Amounts are stored as an arbitrary-precision, non-negative [BigInt] count
/// of "minor units" (e.g. paisa/cents). This avoids the precision loss that
/// comes from routing large currency amounts (e.g. PKR 150,000,000.00 == a
/// minor-unit value of 15,000,000,000) through `double`.
///
/// JSON wire format is always a decimal digit string (e.g. `"15000000000"`).
/// [fromJson] additionally accepts legacy `int`/`num` values so persisted
/// data written before this migration keeps loading correctly.
class MoneyMinor implements Comparable<MoneyMinor> {
  const MoneyMinor._(this.value);

  /// Raw non-negative minor-unit amount.
  final BigInt value;

  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');

  static final MoneyMinor zero = MoneyMinor._(BigInt.zero);

  /// Wraps a [BigInt]. Throws [ArgumentError] if [value] is negative.
  factory MoneyMinor.fromBigInt(BigInt value) {
    if (value.isNegative) {
      throw ArgumentError.value(
        value,
        'value',
        'MoneyMinor cannot be negative',
      );
    }
    return MoneyMinor._(value);
  }

  /// Wraps a legacy `int` minor-unit amount. Throws [ArgumentError] if
  /// [value] is negative.
  factory MoneyMinor.fromInt(int value) {
    return MoneyMinor.fromBigInt(BigInt.from(value));
  }

  /// Parses a strict digits-only minor-unit string (e.g. `"15000000000"`).
  ///
  /// Returns `null` for `null`, empty/blank, or malformed input (signs,
  /// decimal points, commas, whitespace, or scientific notation are all
  /// rejected). Never throws.
  static MoneyMinor? tryParse(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (!_digitsOnly.hasMatch(trimmed)) return null;
    final value = BigInt.tryParse(trimmed);
    if (value == null || value.isNegative) return null;
    return MoneyMinor._(value);
  }

  /// Parses a strict digits-only minor-unit string. Throws [FormatException]
  /// for malformed or empty input.
  factory MoneyMinor.parse(String raw) {
    final parsed = tryParse(raw);
    if (parsed == null) {
      throw FormatException('Invalid minor-unit amount: "$raw"');
    }
    return parsed;
  }

  /// Accepts the current wire format (digit string) as well as legacy
  /// `int`/`num` JSON values. Returns `null` for `null` or corrupt/invalid
  /// values so domain reads (e.g. local cache) never crash on bad data.
  ///
  /// Note: [GoalApiMapper] wraps this to throw [AppException] on corrupt
  /// server responses instead of silently swallowing them — API data
  /// should never be silently wrong, only locally-cached data should be
  /// treated as recoverable-by-omission.
  static MoneyMinor? fromJson(Object? raw) {
    if (raw == null) return null;
    if (raw is String) return tryParse(raw);
    if (raw is int) {
      return raw < 0 ? null : MoneyMinor._(BigInt.from(raw));
    }
    if (raw is num) {
      if (raw.isNaN || raw.isInfinite || raw < 0) return null;
      if (raw != raw.truncateToDouble()) return null;
      return MoneyMinor._(BigInt.from(raw.truncate()));
    }
    return null;
  }

  /// Digit-string wire format, e.g. `"15000000000"`.
  String toJson() => value.toString();

  bool get isZero => value == BigInt.zero;

  bool get isPositive => value > BigInt.zero;

  MoneyMinor operator +(MoneyMinor other) => MoneyMinor._(value + other.value);

  /// Throws [StateError] if the result would be negative. Callers that need
  /// clamped subtraction (e.g. forecasting) should compare/clamp themselves
  /// using [value] rather than relying on this operator.
  MoneyMinor operator -(MoneyMinor other) {
    final result = value - other.value;
    if (result.isNegative) {
      throw StateError('MoneyMinor subtraction would be negative');
    }
    return MoneyMinor._(result);
  }

  bool operator <(MoneyMinor other) => value < other.value;
  bool operator <=(MoneyMinor other) => value <= other.value;
  bool operator >(MoneyMinor other) => value > other.value;
  bool operator >=(MoneyMinor other) => value >= other.value;

  @override
  int compareTo(MoneyMinor other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is MoneyMinor && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
