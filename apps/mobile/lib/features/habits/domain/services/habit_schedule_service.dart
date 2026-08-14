import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/habit.dart';
import '../entities/habit_enums.dart';
import '../entities/habit_history.dart';

/// Schedule/target fields resolved for a specific [LocalDate], sourced from
/// either an applicable [HabitScheduleRevision] or the Habit's current
/// fields when no revision history is supplied.
class HabitEffectiveFields {
  const HabitEffectiveFields({
    required this.goalType,
    required this.targetValue,
    this.unitLabel,
    required this.frequencyType,
    this.selectedWeekdays = const [],
    this.timesPerWeek,
  });

  final HabitGoalType goalType;
  final int targetValue;
  final String? unitLabel;
  final HabitFrequencyType frequencyType;
  final List<int> selectedWeekdays;
  final int? timesPerWeek;
}

/// Pure schedule rules for Habits.
///
/// Week starts on Monday (ISO-8601). Schedule edits affect future dates only;
/// historical check-ins are never rewritten by this service.
///
/// History awareness: [revisions] / [statusPeriods] are optional. When
/// omitted (default `const []`), behavior falls back to the Habit's current
/// `status`/schedule fields exactly as before history tracking existed —
/// this keeps callers that only deal with "today" unaffected. When supplied
/// (from [LocalHabitRepository]), each date is resolved against the
/// effective-dated revision/period that covered it, so a schedule edit or a
/// pause/resume made today never changes how *past* dates are interpreted.
class HabitScheduleService {
  const HabitScheduleService();

  /// The [HabitScheduleRevision] effective on [date] — the latest revision
  /// with `effectiveFrom <= date`. Null when [revisions] is empty or none
  /// apply yet (caller should fall back to the Habit's current fields).
  HabitScheduleRevision? revisionOn(
    List<HabitScheduleRevision> revisions,
    LocalDate date,
  ) {
    HabitScheduleRevision? applicable;
    for (final revision in revisions) {
      if (revision.effectiveFrom.isAfter(date)) continue;
      if (applicable == null) {
        applicable = revision;
        continue;
      }
      final isNewer =
          revision.effectiveFrom.isAfter(applicable.effectiveFrom) ||
          (revision.effectiveFrom == applicable.effectiveFrom &&
              revision.createdAt.isAfter(applicable.createdAt));
      if (isNewer) applicable = revision;
    }
    return applicable;
  }

  /// The [HabitStatus] effective on [date] from [statusPeriods], falling
  /// back to [habit.status] when no period covers it (including when
  /// [statusPeriods] is empty).
  HabitStatus statusOn(
    Habit habit,
    List<HabitStatusPeriod> statusPeriods,
    LocalDate date,
  ) {
    for (final period in statusPeriods) {
      if (period.covers(date)) return period.status;
    }
    return habit.status;
  }

  /// Schedule/target fields effective on [date], from the applicable
  /// revision or [habit]'s current fields when history is absent.
  HabitEffectiveFields fieldsOn(
    Habit habit,
    List<HabitScheduleRevision> revisions,
    LocalDate date,
  ) {
    final revision = revisionOn(revisions, date);
    if (revision == null) {
      return HabitEffectiveFields(
        goalType: habit.goalType,
        targetValue: habit.targetValue,
        unitLabel: habit.unitLabel,
        frequencyType: habit.frequencyType,
        selectedWeekdays: habit.selectedWeekdays,
        timesPerWeek: habit.timesPerWeek,
      );
    }
    return HabitEffectiveFields(
      goalType: revision.goalType,
      targetValue: revision.targetValue,
      unitLabel: revision.unitLabel,
      frequencyType: revision.frequencyType,
      selectedWeekdays: revision.selectedWeekdays,
      timesPerWeek: revision.timesPerWeek,
    );
  }

  bool isActiveForScheduling(
    Habit habit, {
    List<HabitStatusPeriod> statusPeriods = const [],
    LocalDate? date,
  }) {
    if (statusPeriods.isEmpty || date == null) {
      return habit.status == HabitStatus.active;
    }
    return statusOn(habit, statusPeriods, date) == HabitStatus.active;
  }

  /// Whether [date] is a scheduled occurrence.
  ///
  /// A paused/archived status period covering [date] means it is never
  /// scheduled for that date, regardless of the current Habit status.
  bool isScheduledOn(
    Habit habit,
    LocalDate date, {
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    final status = statusOn(habit, statusPeriods, date);
    if (status != HabitStatus.active) return false;
    if (date.isBefore(habit.startDate)) return false;

    final fields = fieldsOn(habit, revisions, date);
    switch (fields.frequencyType) {
      case HabitFrequencyType.daily:
        return true;
      case HabitFrequencyType.selectedWeekdays:
        return fields.selectedWeekdays.contains(date.weekday);
      case HabitFrequencyType.timesPerWeek:
        // Any day on/after start can host an occurrence; weekly cap is
        // enforced by progress/streak semantics (at most one per date).
        return true;
    }
  }

  List<LocalDate> scheduledDatesInRange(
    Habit habit,
    LocalDate start,
    LocalDate endInclusive, {
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    if (endInclusive.isBefore(start)) return const [];
    final out = <LocalDate>[];
    var cursor = start;
    while (!cursor.isAfter(endInclusive)) {
      if (isScheduledOn(
        habit,
        cursor,
        revisions: revisions,
        statusPeriods: statusPeriods,
      )) {
        out.add(cursor);
      }
      cursor = cursor.addDays(1);
    }
    return out;
  }

  int scheduledCountInWeek(
    Habit habit,
    LocalDate anyDayInWeek, {
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    final start = anyDayInWeek.startOfWeek();
    final end = start.addDays(6);
    final fields = fieldsOn(habit, revisions, anyDayInWeek);
    switch (fields.frequencyType) {
      case HabitFrequencyType.daily:
      case HabitFrequencyType.selectedWeekdays:
        return scheduledDatesInRange(
          habit,
          start,
          end,
          revisions: revisions,
          statusPeriods: statusPeriods,
        ).length;
      case HabitFrequencyType.timesPerWeek:
        final target = fields.timesPerWeek ?? 1;
        // Expected occurrences for the week target (capped by remaining days
        // after startDate within the week).
        final available = scheduledDatesInRange(
          habit,
          start,
          end,
          revisions: revisions,
          statusPeriods: statusPeriods,
        ).length;
        return available < target ? available : target;
    }
  }
}
