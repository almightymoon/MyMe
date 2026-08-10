import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';

void main() {
  group('LocalDate.parse', () {
    test('parses valid ISO date', () {
      final date = LocalDate.parse('2026-08-09');
      expect(date.year, 2026);
      expect(date.month, 8);
      expect(date.day, 9);
    });

    test('trims whitespace', () {
      expect(LocalDate.parse('  2026-08-09  '), LocalDate(2026, 8, 9));
    });

    test('rejects invalid format', () {
      final throwsInvalidLocalDate = throwsA(isA<InvalidLocalDateException>());
      expect(() => LocalDate.parse('2026/08/09'), throwsInvalidLocalDate);
      expect(() => LocalDate.parse('08-09-2026'), throwsInvalidLocalDate);
      expect(() => LocalDate.parse('2026-8-9'), throwsInvalidLocalDate);
    });

    test('rejects invalid calendar day', () {
      final throwsInvalidLocalDate = throwsA(isA<InvalidLocalDateException>());
      expect(() => LocalDate.parse('2026-02-30'), throwsInvalidLocalDate);
      expect(() => LocalDate.parse('2026-13-01'), throwsInvalidLocalDate);
    });

    test('tryParse returns null for invalid input', () {
      expect(LocalDate.tryParse('nope'), isNull);
      expect(LocalDate.tryParse('2026-08-09'), LocalDate(2026, 8, 9));
    });
  });

  group('leap year', () {
    test('Feb 29 valid in leap year', () {
      expect(LocalDate.parse('2024-02-29'), LocalDate(2024, 2, 29));
    });

    test('Feb 29 invalid in non-leap year', () {
      expect(
        () => LocalDate.parse('2025-02-29'),
        throwsA(isA<InvalidLocalDateException>()),
      );
    });
  });

  group('addDays', () {
    test('crosses month boundary', () {
      expect(LocalDate(2026, 1, 31).addDays(1), LocalDate(2026, 2, 1));
    });

    test('crosses year boundary', () {
      expect(LocalDate(2025, 12, 31).addDays(1), LocalDate(2026, 1, 1));
    });

    test('handles negative days', () {
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
    });
  });

  group('weekday and week start', () {
    test('weekday matches local DateTime (Monday = 1)', () {
      expect(LocalDate(2026, 8, 10).weekday, DateTime.monday);
      expect(LocalDate(2026, 8, 9).weekday, DateTime.sunday);
    });

    test('startOfWeek is Monday', () {
      // Sunday 2026-08-09 → week starts Monday 2026-08-03
      expect(LocalDate(2026, 8, 9).startOfWeek(), LocalDate(2026, 8, 3));
      // Monday 2026-08-10 → same Monday
      expect(LocalDate(2026, 8, 10).startOfWeek(), LocalDate(2026, 8, 10));
    });

    test('endOfWeek is Sunday', () {
      expect(LocalDate(2026, 8, 9).endOfWeek(), LocalDate(2026, 8, 9));
      expect(LocalDate(2026, 8, 10).endOfWeek(), LocalDate(2026, 8, 16));
    });
  });

  group('equality and ordering', () {
    test('equal dates compare equal', () {
      final a = LocalDate(2026, 8, 9);
      final b = LocalDate(2026, 8, 9);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('compareTo orders chronologically', () {
      final earlier = LocalDate(2026, 8, 8);
      final later = LocalDate(2026, 8, 9);
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isSameOrBefore(later), isTrue);
    });
  });

  group('no UTC drift', () {
    test('fromDateTime uses local calendar fields', () {
      // UTC midnight can be previous local day in negative-offset zones;
      // fromDateTime must use the DateTime's local y/m/d.
      final localMidnight = DateTime(2026, 8, 9);
      expect(LocalDate.fromDateTime(localMidnight), LocalDate(2026, 8, 9));
    });

    test('toIso8601String round-trips without timezone', () {
      final date = LocalDate(2026, 8, 9);
      expect(date.toIso8601String(), '2026-08-09');
      expect(LocalDate.parse(date.toIso8601String()), date);
    });

    test('toDateTimeLocal is local midnight', () {
      final date = LocalDate(2026, 8, 9);
      final dt = date.toDateTimeLocal();
      expect(dt.year, 2026);
      expect(dt.month, 8);
      expect(dt.day, 9);
      expect(dt.hour, 0);
      expect(dt.minute, 0);
    });
  });
}
