import '../../../../core/domain/value_objects/local_date.dart';

/// When a [MemyCalendarEvent] occurs.
///
/// Sealed so every call site (UI, mappers, sync diffing) must handle both
/// [TimedCalendarEventTime] and [AllDayCalendarEventTime] explicitly.
sealed class CalendarEventTime {
  const CalendarEventTime();

  /// Inclusive UTC instant the event starts.
  DateTime get startUtc;

  /// Exclusive UTC instant the event ends (all-day: midnight of the day
  /// *after* the last day, matching device_calendar's own convention).
  DateTime get endUtc;

  bool get isAllDay;
}

/// A specific start/end instant, e.g. "10:00–11:00".
class TimedCalendarEventTime extends CalendarEventTime {
  TimedCalendarEventTime({
    required this.startUtc,
    required this.endUtc,
    this.timezoneName,
  }) {
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError('endUtc must be after startUtc');
    }
  }

  @override
  final DateTime startUtc;

  @override
  final DateTime endUtc;

  /// IANA name (e.g. `Asia/Karachi`) the times were authored in, if known.
  final String? timezoneName;

  @override
  bool get isAllDay => false;

  TimedCalendarEventTime copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
    String? timezoneName,
  }) {
    return TimedCalendarEventTime(
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      timezoneName: timezoneName ?? this.timezoneName,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TimedCalendarEventTime &&
      other.startUtc == startUtc &&
      other.endUtc == endUtc &&
      other.timezoneName == timezoneName;

  @override
  int get hashCode => Object.hash(startUtc, endUtc, timezoneName);

  @override
  String toString() => 'TimedCalendarEventTime($startUtc – $endUtc)';
}

/// A whole-day (or multi-day) event with no meaningful time-of-day.
class AllDayCalendarEventTime extends CalendarEventTime {
  AllDayCalendarEventTime({
    required this.startDate,
    required this.endDateInclusive,
  }) {
    if (endDateInclusive.isBefore(startDate)) {
      throw ArgumentError('endDateInclusive must not be before startDate');
    }
  }

  final LocalDate startDate;
  final LocalDate endDateInclusive;

  @override
  DateTime get startUtc => startDate.toDateTimeUtc();

  @override
  DateTime get endUtc => endDateInclusive.addDays(1).toDateTimeUtc();

  @override
  bool get isAllDay => true;

  AllDayCalendarEventTime copyWith({
    LocalDate? startDate,
    LocalDate? endDateInclusive,
  }) {
    return AllDayCalendarEventTime(
      startDate: startDate ?? this.startDate,
      endDateInclusive: endDateInclusive ?? this.endDateInclusive,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AllDayCalendarEventTime &&
      other.startDate == startDate &&
      other.endDateInclusive == endDateInclusive;

  @override
  int get hashCode => Object.hash(startDate, endDateInclusive);

  @override
  String toString() =>
      'AllDayCalendarEventTime($startDate – $endDateInclusive)';
}

extension CalendarEventTimeJson on CalendarEventTime {
  Map<String, dynamic> toJson() {
    return {
      'isAllDay': isAllDay,
      'startUtc': startUtc.toIso8601String(),
      'endUtc': endUtc.toIso8601String(),
      if (this is TimedCalendarEventTime)
        'timezoneName': (this as TimedCalendarEventTime).timezoneName,
    };
  }
}

CalendarEventTime calendarEventTimeFromJson(Map<String, dynamic> json) {
  return calendarEventTimeFromStorage(
    isAllDay: json['isAllDay'] as bool,
    startUtc: DateTime.parse(json['startUtc'] as String),
    endUtc: DateTime.parse(json['endUtc'] as String),
    timezoneName: json['timezoneName'] as String?,
  );
}

/// Reconstructs a [CalendarEventTime] from flat storage columns
/// (used by the Drift mapper and gateway adapters).
CalendarEventTime calendarEventTimeFromStorage({
  required bool isAllDay,
  required DateTime startUtc,
  required DateTime endUtc,
  String? timezoneName,
}) {
  if (!isAllDay) {
    return TimedCalendarEventTime(
      startUtc: startUtc,
      endUtc: endUtc,
      timezoneName: timezoneName,
    );
  }
  final startDate = LocalDate.fromDateTime(startUtc);
  final lastMoment = endUtc.subtract(const Duration(seconds: 1));
  final endDate = LocalDate.fromDateTime(lastMoment);
  return AllDayCalendarEventTime(
    startDate: startDate,
    endDateInclusive: endDate,
  );
}
