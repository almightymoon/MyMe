/// Calendar month without a day component (`YYYY-MM`).
class YearMonth implements Comparable<YearMonth> {
  factory YearMonth(int year, int month) {
    if (year < 1) {
      throw ArgumentError.value(year, 'year', 'must be >= 1');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be 1–12');
    }
    return YearMonth._(year, month);
  }

  const YearMonth._(this.year, this.month);

  final int year;
  final int month;

  factory YearMonth.fromDateTime(DateTime dateTime) =>
      YearMonth(dateTime.year, dateTime.month);

  static YearMonth? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return parse(raw);
    } catch (_) {
      return null;
    }
  }

  static YearMonth parse(String raw) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(raw.trim());
    if (match == null) {
      throw FormatException('Invalid YearMonth: $raw');
    }
    return YearMonth(int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  String toIso8601String() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  /// Inclusive first day of the month.
  DateTime get startLocal => DateTime(year, month, 1);

  /// Exclusive first day of the next month.
  DateTime get endExclusiveLocal {
    final next = nextMonth;
    return DateTime(next.year, next.month, 1);
  }

  YearMonth get nextMonth {
    if (month == 12) return YearMonth(year + 1, 1);
    return YearMonth(year, month + 1);
  }

  YearMonth get previousMonth {
    if (month == 1) return YearMonth(year - 1, 12);
    return YearMonth(year, month - 1);
  }

  @override
  int compareTo(YearMonth other) {
    final y = year.compareTo(other.year);
    if (y != 0) return y;
    return month.compareTo(other.month);
  }

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => toIso8601String();
}
