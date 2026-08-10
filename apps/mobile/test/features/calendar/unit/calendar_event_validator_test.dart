import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/calendar/domain/services/calendar_event_validator.dart';

void main() {
  group('CalendarEventValidator.validateTitle', () {
    test('trims and accepts a valid title', () {
      expect(
        CalendarEventValidator.validateTitle('  Team standup  '),
        'Team standup',
      );
    });

    test('rejects empty title', () {
      expect(
        () => CalendarEventValidator.validateTitle('   '),
        throwsA(isA<CalendarEventValidationException>()),
      );
    });

    test('rejects titles over the max length', () {
      final tooLong = 'a' * (CalendarEventValidator.maxTitleLength + 1);
      expect(
        () => CalendarEventValidator.validateTitle(tooLong),
        throwsA(isA<CalendarEventValidationException>()),
      );
    });
  });

  group('CalendarEventValidator.validateNotes/validateLocation', () {
    test('null/empty notes and location normalize to null', () {
      expect(CalendarEventValidator.validateNotes(null), isNull);
      expect(CalendarEventValidator.validateNotes('   '), isNull);
      expect(CalendarEventValidator.validateLocation(''), isNull);
    });

    test('rejects notes over the max length', () {
      final tooLong = 'a' * (CalendarEventValidator.maxNotesLength + 1);
      expect(
        () => CalendarEventValidator.validateNotes(tooLong),
        throwsA(isA<CalendarEventValidationException>()),
      );
    });

    test('rejects location over the max length', () {
      final tooLong = 'a' * (CalendarEventValidator.maxLocationLength + 1);
      expect(
        () => CalendarEventValidator.validateLocation(tooLong),
        throwsA(isA<CalendarEventValidationException>()),
      );
    });
  });

  group('CalendarEventValidator.validateReminderMinutes', () {
    test('sorts and de-duplicates', () {
      expect(CalendarEventValidator.validateReminderMinutes([30, 15, 30]), [
        15,
        30,
      ]);
    });

    test('rejects negative reminder minutes', () {
      expect(
        () => CalendarEventValidator.validateReminderMinutes([-5]),
        throwsA(isA<CalendarEventValidationException>()),
      );
    });
  });
}
