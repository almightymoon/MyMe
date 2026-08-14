/// Thrown when a [LocalDate] cannot represent a real calendar day.
class InvalidLocalDateException implements Exception {
  InvalidLocalDateException(this.message);
  final String message;

  @override
  String toString() => 'InvalidLocalDateException: $message';
}

/// Calendar date without time or timezone ambiguity.
///
/// Serialized exclusively as `YYYY-MM-DD`. Do not store check-in dates as
/// UTC midnight timestamps.
///
/// Week start is **Monday** (ISO-8601). Calendar arithmetic uses UTC midday
/// to avoid DST skip/duplication when adding days.
class LocalDate implements Comparable<LocalDate> {
  /// Creates a validated calendar date. Rejects impossible days such as
  /// 2026-02-31 at runtime (not only via assert).
  factory LocalDate(int year, int month, int day) {
    _validate(year, month, day);
    return LocalDate._(year, month, day);
  }

  const LocalDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static void _validate(int year, int month, int day) {
    if (year < 1) {
      throw InvalidLocalDateException('year must be >= 1, got $year');
    }
    if (month < 1 || month > 12) {
      throw InvalidLocalDateException('month must be 1–12, got $month');
    }
    if (day < 1 || day > 31) {
      throw InvalidLocalDateException('day must be 1–31, got $day');
    }
    // Validate via UTC to avoid local DST reinterpretation of the civil date.
    final probe = DateTime.utc(year, month, day);
    if (probe.year != year || probe.month != month || probe.day != day) {
      throw InvalidLocalDateException(
        'not a real calendar day: '
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}',
      );
    }
  }

  /// Monday = 1 … Sunday = 7 (ISO-8601).
  int get weekday => DateTime.utc(year, month, day).weekday;

  static LocalDate fromDateTime(DateTime dateTime) {
    // Interpret the caller's wall-calendar fields; do not convert timezone.
    return LocalDate(dateTime.year, dateTime.month, dateTime.day);
  }

  static LocalDate? tryParse(String raw) {
    try {
      return parse(raw);
    } catch (_) {
      return null;
    }
  }

  static LocalDate parse(String raw) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw.trim());
    if (match == null) {
      throw InvalidLocalDateException('Invalid LocalDate format: $raw');
    }
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    return LocalDate(y, m, d);
  }

  String toIso8601String() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Adds [days] using UTC midday so DST transitions cannot skip/duplicate dates.
  LocalDate addDays(int days) {
    final utcMidday = DateTime.utc(year, month, day, 12);
    final shifted = utcMidday.add(Duration(days: days));
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  /// Monday-start week containing this date.
  LocalDate startOfWeek() {
    return addDays(-(weekday - DateTime.monday));
  }

  LocalDate endOfWeek() {
    return startOfWeek().addDays(6);
  }

  /// Local midnight for UI widgets that need a DateTime.
  DateTime toDateTimeLocal() => DateTime(year, month, day);

  /// UTC midnight corresponding to this civil date (not a local instant).
  DateTime toDateTimeUtc() => DateTime.utc(year, month, day);

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;
  bool isSameOrBefore(LocalDate other) => compareTo(other) <= 0;
  bool isSameOrAfter(LocalDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}
