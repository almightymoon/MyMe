import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/domain/services/money_format.dart';
import 'package:memy/features/goals/domain/value_objects/money_minor.dart';

void main() {
  group('MoneyMinor.parse / tryParse', () {
    test('parses plain digit strings', () {
      expect(MoneyMinor.parse('0').value, BigInt.zero);
      expect(
        MoneyMinor.parse('15000000000').value,
        BigInt.parse('15000000000'),
      );
    });

    test('tryParse returns null for empty/blank/null', () {
      expect(MoneyMinor.tryParse(null), isNull);
      expect(MoneyMinor.tryParse(''), isNull);
      expect(MoneyMinor.tryParse('   '), isNull);
    });

    test(
      'rejects negative, decimal, comma, whitespace, scientific notation',
      () {
        for (final bad in [
          '-5',
          '100.5',
          '1,000',
          '1 000',
          '1e5',
          '+5',
          'abc',
        ]) {
          expect(
            MoneyMinor.tryParse(bad),
            isNull,
            reason: 'expected "$bad" to be rejected',
          );
          expect(() => MoneyMinor.parse(bad), throwsFormatException);
        }
      },
    );

    test('MoneyMinor.parse rejects whole-minor decimal input like "100.5"', () {
      expect(() => MoneyMinor.parse('100.5'), throwsFormatException);
    });
  });

  group('MoneyMinor.fromInt / fromBigInt legacy + validation', () {
    test('fromInt handles legacy large int amounts precisely', () {
      final money = MoneyMinor.fromInt(15000000000);
      expect(money.value, BigInt.parse('15000000000'));
      expect(money.toJson(), '15000000000');
    });

    test('fromBigInt/fromInt throw ArgumentError for negative values', () {
      expect(() => MoneyMinor.fromInt(-1), throwsArgumentError);
      expect(() => MoneyMinor.fromBigInt(BigInt.from(-1)), throwsArgumentError);
    });
  });

  group('MoneyMinor.fromJson', () {
    test('returns null for null', () {
      expect(MoneyMinor.fromJson(null), isNull);
    });

    test('accepts current string wire format', () {
      final money = MoneyMinor.fromJson('15000000000');
      expect(money, isNotNull);
      expect(money!.value, BigInt.parse('15000000000'));
    });

    test('accepts legacy int JSON', () {
      final money = MoneyMinor.fromJson(15000000000);
      expect(money, isNotNull);
      expect(money!.value, BigInt.parse('15000000000'));
    });

    test('accepts legacy whole-number num/double JSON', () {
      final money = MoneyMinor.fromJson(100000.0);
      expect(money, isNotNull);
      expect(money!.value, BigInt.from(100000));
    });

    test(
      'returns null for corrupt values (negative, fractional, malformed string)',
      () {
        expect(MoneyMinor.fromJson(-5), isNull);
        expect(MoneyMinor.fromJson(-5.0), isNull);
        expect(MoneyMinor.fromJson(5.5), isNull);
        expect(MoneyMinor.fromJson('not-a-number'), isNull);
        expect(MoneyMinor.fromJson('-5'), isNull);
        expect(MoneyMinor.fromJson('5.5'), isNull);
        expect(MoneyMinor.fromJson(true), isNull);
      },
    );
  });

  group('MoneyMinor equality / comparison', () {
    test('equal values are == and share hashCode', () {
      final a = MoneyMinor.fromInt(500);
      final b = MoneyMinor.parse('500');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('compareTo and comparison operators', () {
      final small = MoneyMinor.fromInt(100);
      final big = MoneyMinor.fromInt(200);
      expect(small.compareTo(big), lessThan(0));
      expect(small < big, isTrue);
      expect(big > small, isTrue);
      expect(small <= small, isTrue);
      expect(big >= big, isTrue);
    });

    test('isZero and isPositive', () {
      expect(MoneyMinor.zero.isZero, isTrue);
      expect(MoneyMinor.zero.isPositive, isFalse);
      expect(MoneyMinor.fromInt(1).isPositive, isTrue);
    });

    test('toString returns the digit string', () {
      expect(MoneyMinor.fromInt(15000000000).toString(), '15000000000');
    });
  });

  group('MoneyMinor operators', () {
    test('addition', () {
      final sum = MoneyMinor.fromInt(100) + MoneyMinor.fromInt(50);
      expect(sum, MoneyMinor.fromInt(150));
    });

    test('subtraction throws StateError on negative result', () {
      expect(
        () => MoneyMinor.fromInt(50) - MoneyMinor.fromInt(100),
        throwsStateError,
      );
    });

    test('subtraction succeeds when result is non-negative', () {
      expect(
        MoneyMinor.fromInt(150) - MoneyMinor.fromInt(50),
        MoneyMinor.fromInt(100),
      );
    });
  });

  group('MoneyFormat.formatMinor', () {
    test('formats whole major amounts with thousands separators', () {
      expect(
        MoneyFormat.formatMinor(MoneyMinor.fromInt(15000000000), 'PKR'),
        'PKR 150,000,000',
      );
    });

    test('formats fractional amounts with 2 decimal places', () {
      expect(
        MoneyFormat.formatMinor(MoneyMinor.fromInt(150050), 'PKR'),
        'PKR 1,500.50',
      );
    });

    test('formats zero', () {
      expect(MoneyFormat.formatMinor(MoneyMinor.zero, 'PKR'), 'PKR 0');
    });
  });

  group('MoneyFormat.parseMajorToMinor', () {
    test('parses whole major string without decimal', () {
      final minor = MoneyFormat.parseMajorToMinor('150000000');
      expect(minor, MoneyMinor.fromInt(15000000000));
    });

    test('parses major string with 2 fraction digits precisely', () {
      final minor = MoneyFormat.parseMajorToMinor('150000000.50');
      expect(minor, MoneyMinor.fromInt(15000000050));
    });

    test('parses major string with 1 fraction digit (padded)', () {
      final minor = MoneyFormat.parseMajorToMinor('10.5');
      expect(minor, MoneyMinor.fromInt(1050));
    });

    test('strips thousands separators before parsing', () {
      final minor = MoneyFormat.parseMajorToMinor('150,000,000');
      expect(minor, MoneyMinor.fromInt(15000000000));
    });

    test('returns null for empty/blank input', () {
      expect(MoneyFormat.parseMajorToMinor(null), isNull);
      expect(MoneyFormat.parseMajorToMinor(''), isNull);
      expect(MoneyFormat.parseMajorToMinor('   '), isNull);
    });

    test('throws FormatException for invalid input', () {
      expect(() => MoneyFormat.parseMajorToMinor('abc'), throwsFormatException);
      expect(
        () => MoneyFormat.parseMajorToMinor('1.234'),
        throwsFormatException,
      );
      expect(() => MoneyFormat.parseMajorToMinor('-5'), throwsFormatException);
    });
  });

  group('MoneyFormat.majorStringFromMinor', () {
    test('returns empty string for null', () {
      expect(MoneyFormat.majorStringFromMinor(null), '');
    });

    test('round-trips whole and fractional amounts', () {
      expect(
        MoneyFormat.majorStringFromMinor(MoneyMinor.fromInt(15000000000)),
        '150000000',
      );
      expect(
        MoneyFormat.majorStringFromMinor(MoneyMinor.fromInt(15000000050)),
        '150000000.50',
      );
    });
  });
}
