import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/year_month.dart';

void main() {
  test('serializes and compares', () {
    final month = YearMonth(2026, 8);
    expect(month.toIso8601String(), '2026-08');
    expect(YearMonth.parse('2026-08'), month);
    expect(month.nextMonth, YearMonth(2026, 9));
    expect(month.previousMonth, YearMonth(2026, 7));
    expect(YearMonth(2026, 12).nextMonth, YearMonth(2027, 1));
    expect(YearMonth(2026, 1).previousMonth, YearMonth(2025, 12));
    expect(month.compareTo(YearMonth(2026, 9)), lessThan(0));
  });

  test('leap-year February bounds', () {
    final leap = YearMonth(2024, 2);
    expect(leap.startLocal, DateTime(2024, 2, 1));
    expect(leap.endExclusiveLocal, DateTime(2024, 3, 1));
    expect(leap.endExclusiveLocal.difference(leap.startLocal).inDays, 29);

    final common = YearMonth(2025, 2);
    expect(common.endExclusiveLocal.difference(common.startLocal).inDays, 28);
  });

  test('rejects invalid values', () {
    expect(() => YearMonth(0, 1), throwsArgumentError);
    expect(() => YearMonth(2026, 0), throwsArgumentError);
    expect(() => YearMonth(2026, 13), throwsArgumentError);
    expect(YearMonth.tryParse('2026/08'), isNull);
  });
}
