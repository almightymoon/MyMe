/// Calendar date without time or timezone ambiguity.
///
/// Serialized exclusively as `YYYY-MM-DD`. Do not store check-in dates as
/// UTC midnight timestamps.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day)
    : assert(year >= 1),
      assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 31);

  final int year;
  final int month;
  final int day;

  /// Monday = 1 … Sunday = 7 (ISO-8601).
  int get weekday {
    return DateTime(year, month, day).weekday;
  }

  static LocalDate fromDateTime(DateTime dateTime) {
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
      throw FormatException('Invalid LocalDate: $raw');
    }
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    final dt = DateTime(y, m, d);
    if (dt.year != y || dt.month != m || dt.day != d) {
      throw FormatException('Invalid LocalDate calendar day: $raw');
    }
    return LocalDate(y, m, d);
  }

  String toIso8601String() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  LocalDate addDays(int days) {
    return LocalDate.fromDateTime(
      DateTime(year, month, day).add(Duration(days: days)),
    );
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
