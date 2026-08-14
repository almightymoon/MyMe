import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/services/calendar_event_validator.dart';

void main() {
  group('TimedCalendarEventTime', () {
    test('rejects a non-positive duration', () {
      final start = DateTime.utc(2026, 1, 1, 10);
      expect(
        () => TimedCalendarEventTime(startUtc: start, endUtc: start),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON', () {
      final time = TimedCalendarEventTime(
        startUtc: DateTime.utc(2026, 1, 1, 10),
        endUtc: DateTime.utc(2026, 1, 1, 11),
        timezoneName: 'UTC',
      );
      final json = time.toJson();
      final restored = calendarEventTimeFromJson(json);
      expect(restored, isA<TimedCalendarEventTime>());
      expect(restored.startUtc, time.startUtc);
      expect(restored.endUtc, time.endUtc);
      expect(restored.isAllDay, isFalse);
    });
  });

  group('AllDayCalendarEventTime', () {
    test('spans a whole exclusive-end UTC day range for a single day', () {
      final time = AllDayCalendarEventTime(
        startDate: LocalDate(2026, 3, 1),
        endDateInclusive: LocalDate(2026, 3, 1),
      );
      expect(time.startUtc, DateTime.utc(2026, 3, 1));
      expect(time.endUtc, DateTime.utc(2026, 3, 2));
      expect(time.isAllDay, isTrue);
    });

    test('rejects an end date before the start date', () {
      expect(
        () => AllDayCalendarEventTime(
          startDate: LocalDate(2026, 3, 5),
          endDateInclusive: LocalDate(2026, 3, 1),
        ),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON preserving the inclusive day range', () {
      final time = AllDayCalendarEventTime(
        startDate: LocalDate(2026, 3, 1),
        endDateInclusive: LocalDate(2026, 3, 3),
      );
      final restored = calendarEventTimeFromJson(time.toJson());
      expect(restored, isA<AllDayCalendarEventTime>());
      final allDay = restored as AllDayCalendarEventTime;
      expect(allDay.startDate, LocalDate(2026, 3, 1));
      expect(allDay.endDateInclusive, LocalDate(2026, 3, 3));
    });
  });

  group('CalendarEventValidator.validateTimeRange', () {
    test('accepts a valid timed range', () {
      final time = TimedCalendarEventTime(
        startUtc: DateTime.utc(2026, 1, 1, 10),
        endUtc: DateTime.utc(2026, 1, 1, 11),
      );
      expect(
        () => CalendarEventValidator.validateTimeRange(time),
        returnsNormally,
      );
    });
  });
}
