import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/habits/data/repositories/local_habit_repository.dart';
import 'package:memy/features/habits/domain/entities/habit.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';
import 'package:memy/features/habits/domain/entities/habit_progress.dart';
import 'package:memy/features/habits/domain/services/habit_progress_service.dart';
import 'package:memy/features/habits/domain/services/habit_schedule_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late FixedAppClock clock;
  late LocalHabitRepository repo;

  var fixedNow = DateTime(2026, 8, 9, 12);
  LocalDate today() => LocalDate.fromDateTime(fixedNow);

  Habit dailyHabit({
    String id = 'habit_daily',
    LocalDate? startDate,
    int targetValue = 1,
    HabitGoalType goalType = HabitGoalType.binary,
  }) {
    return Habit(
      id: id,
      name: 'Read',
      category: HabitCategory.learning,
      status: HabitStatus.active,
      goalType: goalType,
      targetValue: targetValue,
      frequencyType: HabitFrequencyType.daily,
      startDate: startDate ?? today().addDays(-10),
      iconKey: 'book',
      colorKey: 'ember',
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fixedNow = DateTime(2026, 8, 9, 12);
    clock = FixedAppClock(fixedNow);
    repo = LocalHabitRepository(
      prefs: prefs,
      clock: clock,
      seedHabitsBuilder: (_, _) => const [],
      seedCheckInsBuilder: (_, _) => const [],
      idGenerator: () => 'id_${_HistoryTestIds.next()}',
    );
  });

  group('createHabit writes initial history', () {
    test(
      'one revision and one open status period from current fields',
      () async {
        final habit = dailyHabit();
        await repo.createHabit(habit);

        final revisions = await repo.getScheduleRevisions(habit.id);
        final periods = await repo.getStatusPeriods(habit.id);

        expect(revisions, hasLength(1));
        expect(revisions.first.effectiveFrom, habit.startDate);
        expect(revisions.first.targetValue, habit.targetValue);
        expect(revisions.first.frequencyType, habit.frequencyType);

        expect(periods, hasLength(1));
        expect(periods.first.status, HabitStatus.active);
        expect(periods.first.effectiveFrom, habit.startDate);
        expect(periods.first.effectiveUntil, isNull);
      },
    );
  });

  group('pause mid-streak', () {
    test('paused days are excluded from scheduling and streak', () async {
      final start = today().addDays(-6); // 6 days ago
      final habit = dailyHabit(startDate: start);
      await repo.createHabit(habit);

      // Complete every day from start through today - 2.
      var cursor = start;
      while (cursor.isSameOrBefore(today().addDays(-2))) {
        await repo.upsertCheckIn(
          HabitCheckInDraft(habitId: habit.id, localDate: cursor, value: 1),
        );
        cursor = cursor.addDays(1);
      }

      // Pause today (yesterday's completion stands; today+ excluded).
      await repo.pauseHabit(habit.id);

      final periods = await repo.getStatusPeriods(habit.id);
      expect(periods, hasLength(2));
      expect(periods.first.status, HabitStatus.active);
      expect(periods.first.effectiveUntil, today().addDays(-1));
      expect(periods.last.status, HabitStatus.paused);
      expect(periods.last.effectiveFrom, today());
      expect(periods.last.effectiveUntil, isNull);

      // Overview for today shows the habit as not scheduled while paused.
      final overviewToday = await repo.getOverview(today());
      expect(overviewToday.items.where((i) => i.habit.id == habit.id), isEmpty);

      // Yesterday (still active then) reports the streak up to that point.
      final progress = HabitProgressService(
        scheduleService: const HabitScheduleService(),
      );
      final revisions = await repo.getScheduleRevisions(habit.id);
      final refreshedPeriods = await repo.getStatusPeriods(habit.id);
      final refreshedHabit = await repo.getHabit(habit.id);
      final checkIns = await repo.getCheckInsForHabit(habit.id);
      final streakYesterday = progress.streakSummary(
        habit: refreshedHabit!,
        checkIns: checkIns,
        today: today().addDays(-1),
        revisions: revisions,
        statusPeriods: refreshedPeriods,
      );
      expect(streakYesterday.currentStreak, 5);

      // Resume — a new active period opens; the pause gap is preserved.
      await repo.resumeHabit(habit.id);
      final periodsAfterResume = await repo.getStatusPeriods(habit.id);
      expect(periodsAfterResume, hasLength(3));
      expect(periodsAfterResume.last.status, HabitStatus.active);
      expect(periodsAfterResume.last.effectiveFrom, today());
    });
  });

  group('schedule edit does not rewrite the past', () {
    test(
      'target increase today keeps old check-ins interpreted at old target',
      () async {
        final start = today().addDays(-5);
        final habit = dailyHabit(
          startDate: start,
          targetValue: 5,
          goalType: HabitGoalType.count,
        );
        await repo.createHabit(habit);

        // Backfill a check-in for 3 days ago at the original target (5).
        final threeDaysAgo = today().addDays(-3);
        final checkIn = await repo.upsertCheckIn(
          HabitCheckInDraft(
            habitId: habit.id,
            localDate: threeDaysAgo,
            value: 5,
          ),
        );
        expect(checkIn.isCompleted, isTrue);

        // Raise the target today — a new revision is appended, effective today.
        final current = (await repo.getHabit(habit.id))!;
        await repo.updateHabit(current.copyWith(targetValue: 10));

        final revisions = await repo.getScheduleRevisions(habit.id);
        expect(revisions, hasLength(2));
        expect(revisions.last.targetValue, 10);
        expect(revisions.last.effectiveFrom, today());

        // The historical check-in's stored completion is untouched.
        final checkIns = await repo.getCheckInsForHabit(habit.id);
        final historical = checkIns.firstWhere(
          (c) => c.localDate == threeDaysAgo,
        );
        expect(historical.isCompleted, isTrue);
        expect(historical.value, 5);

        // A brand-new backfilled check-in for that same past date still
        // resolves completion against the target that applied *then* (5),
        // not the new target (10) — even though the new revision now exists.
        final schedule = const HabitScheduleService();
        final fieldsThen = schedule.fieldsOn(current, revisions, threeDaysAgo);
        expect(fieldsThen.targetValue, 5);
        final fieldsNow = schedule.fieldsOn(current, revisions, today());
        expect(fieldsNow.targetValue, 10);

        // Today's (new) check-in uses the new target.
        final todayCheckIn = await repo.upsertCheckIn(
          HabitCheckInDraft(habitId: habit.id, localDate: today(), value: 5),
        );
        expect(todayCheckIn.isCompleted, isFalse); // 5 < new target 10
      },
    );

    test('frequency change does not alter past scheduled dates', () async {
      final start = today().addDays(-10);
      final habit = dailyHabit(startDate: start);
      await repo.createHabit(habit);

      final overviewPastBefore = await repo.getOverview(today().addDays(-5));
      final scheduledBefore = overviewPastBefore.scheduledToday;

      final current = (await repo.getHabit(habit.id))!;
      await repo.updateHabit(
        current.copyWith(
          frequencyType: HabitFrequencyType.selectedWeekdays,
          selectedWeekdays: const [DateTime.monday],
        ),
      );

      final overviewPastAfter = await repo.getOverview(today().addDays(-5));
      expect(overviewPastAfter.scheduledToday, scheduledBefore);
    });
  });

  group('v1 → v2 migration', () {
    test('backfills history for pre-existing v1 habits', () async {
      final habit = dailyHabit(id: 'legacy_habit');
      await prefs.setBool(LocalHabitRepository.initializedKey, true);
      await prefs.setString(
        LocalHabitRepository.storageKey,
        jsonEncode({
          'schemaVersion': 1,
          'habits': [habit.toJson()],
          'checkIns': <Map<String, dynamic>>[],
        }),
      );

      final migrated = LocalHabitRepository(prefs: prefs, clock: clock);
      final revisions = await migrated.getScheduleRevisions('legacy_habit');
      final periods = await migrated.getStatusPeriods('legacy_habit');

      expect(revisions, hasLength(1));
      expect(revisions.first.effectiveFrom, habit.startDate);
      expect(revisions.first.targetValue, habit.targetValue);
      expect(periods, hasLength(1));
      expect(periods.first.status, HabitStatus.active);

      // Re-persisted document is now v2 with history included.
      final raw = prefs.getString(LocalHabitRepository.storageKey);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], 2);
      expect(decoded['scheduleRevisions'], hasLength(1));
      expect(decoded['statusPeriods'], hasLength(1));
    });

    test('does not duplicate history on repeated loads', () async {
      final habit = dailyHabit(id: 'legacy_habit_2');
      await prefs.setBool(LocalHabitRepository.initializedKey, true);
      await prefs.setString(
        LocalHabitRepository.storageKey,
        jsonEncode({
          'schemaVersion': 1,
          'habits': [habit.toJson()],
          'checkIns': <Map<String, dynamic>>[],
        }),
      );

      final first = LocalHabitRepository(prefs: prefs, clock: clock);
      await first.ensureInitialized();

      final second = LocalHabitRepository(prefs: prefs, clock: clock);
      final revisions = await second.getScheduleRevisions('legacy_habit_2');
      final periods = await second.getStatusPeriods('legacy_habit_2');
      expect(revisions, hasLength(1));
      expect(periods, hasLength(1));
    });
  });
}

class _HistoryTestIds {
  static int _counter = 0;
  static int next() => _counter++;
}
