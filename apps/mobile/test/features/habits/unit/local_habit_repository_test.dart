import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/habits/data/repositories/local_habit_repository.dart';
import 'package:memy/features/habits/data/seed/habits_seed.dart';
import 'package:memy/features/habits/domain/entities/habit.dart';
import 'package:memy/features/habits/domain/entities/habit_check_in.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';
import 'package:memy/features/habits/domain/entities/habit_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late FixedAppClock clock;
  late LocalHabitRepository repo;

  final fixedNow = DateTime(2026, 8, 9, 12);
  final today = LocalDate.fromDateTime(fixedNow);

  Habit sampleHabit({String id = 'habit_test'}) {
    return Habit(
      id: id,
      name: 'Morning Walk',
      category: HabitCategory.fitness,
      status: HabitStatus.active,
      goalType: HabitGoalType.binary,
      targetValue: 1,
      frequencyType: HabitFrequencyType.daily,
      startDate: today,
      iconKey: 'walk',
      colorKey: 'ember',
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    clock = FixedAppClock(fixedNow);
    repo = LocalHabitRepository(
      prefs: prefs,
      clock: clock,
      seedHabitsBuilder: (_, _) => [sampleHabit()],
      seedCheckInsBuilder: (_, _) => const [],
      idGenerator: () => 'generated-id',
    );
  });

  test('seeds once when storage is uninitialized', () async {
    final first = await repo.getHabits();
    expect(first, hasLength(1));
    expect(first.first.name, 'Morning Walk');

    await repo.deleteHabit(first.first.id);
    expect(await repo.getHabits(), isEmpty);

    final again = LocalHabitRepository(
      prefs: prefs,
      clock: clock,
      seedHabitsBuilder: (_, _) => first,
    );
    expect(await again.getHabits(), isEmpty);
  });

  test('deleting all habits does not reseed', () async {
    final seeded = await repo.getHabits();
    for (final h in seeded) {
      await repo.deleteHabit(h.id);
    }
    expect(await repo.getHabits(), isEmpty);

    final reopened = LocalHabitRepository(prefs: prefs, clock: clock);
    expect(await reopened.getHabits(), isEmpty);
  });

  test(
    'create/get/update/pause/resume/archive/restore/delete with check-ins',
    () async {
      await repo.ensureInitialized();
      for (final h in await repo.getHabits()) {
        await repo.deleteHabit(h.id);
      }

      final created = await repo.createHabit(sampleHabit(id: 'h-crud'));
      expect(await repo.getHabit('h-crud'), isNotNull);

      await repo.updateHabit(
        created.copyWith(name: 'Evening Walk', updatedAt: fixedNow),
      );
      expect((await repo.getHabit('h-crud'))!.name, 'Evening Walk');

      await repo.upsertCheckIn(
        HabitCheckInDraft(habitId: 'h-crud', localDate: today, value: 1),
      );
      expect(await repo.getCheckInsForHabit('h-crud'), hasLength(1));

      final paused = await repo.pauseHabit('h-crud');
      expect(paused.status, HabitStatus.paused);

      final resumed = await repo.resumeHabit('h-crud');
      expect(resumed.status, HabitStatus.active);

      final archived = await repo.archiveHabit('h-crud');
      expect(archived.status, HabitStatus.archived);

      final restored = await repo.restoreHabit('h-crud');
      expect(restored.status, HabitStatus.active);

      await repo.deleteHabit('h-crud');
      expect(await repo.getHabit('h-crud'), isNull);
      expect(await repo.getCheckInsForHabit('h-crud'), isEmpty);
    },
  );

  test('watch emits after mutations', () async {
    await repo.ensureInitialized();
    for (final h in await repo.getHabits()) {
      await repo.deleteHabit(h.id);
    }

    final events = <int>[];
    final sub = repo.watchHabits().listen((list) => events.add(list.length));
    await Future<void>.delayed(Duration.zero);

    await repo.createHabit(sampleHabit(id: 'watched'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, contains(1));
  });

  test(
    'upsert one check-in per habit/date; update does not duplicate',
    () async {
      await repo.ensureInitialized();
      for (final h in await repo.getHabits()) {
        await repo.deleteHabit(h.id);
      }
      await repo.createHabit(sampleHabit(id: 'h-ci'));

      final first = await repo.upsertCheckIn(
        HabitCheckInDraft(habitId: 'h-ci', localDate: today, value: 1),
      );
      final second = await repo.upsertCheckIn(
        HabitCheckInDraft(
          habitId: 'h-ci',
          localDate: today,
          value: 1,
          note: 'Done',
        ),
      );

      expect(second.id, first.id);
      expect(await repo.getCheckInsForHabit('h-ci'), hasLength(1));
      expect(second.note, 'Done');
    },
  );

  test('remove check-in deletes entry', () async {
    await repo.ensureInitialized();
    for (final h in await repo.getHabits()) {
      await repo.deleteHabit(h.id);
    }
    await repo.createHabit(sampleHabit(id: 'h-rm'));
    await repo.upsertCheckIn(
      HabitCheckInDraft(habitId: 'h-rm', localDate: today, value: 1),
    );
    await repo.removeCheckIn(habitId: 'h-rm', localDate: today);
    expect(await repo.getCheckInsForHabit('h-rm'), isEmpty);
  });

  test('persistence survives repository recreation', () async {
    await repo.ensureInitialized();
    for (final h in await repo.getHabits()) {
      await repo.deleteHabit(h.id);
    }
    await repo.createHabit(sampleHabit(id: 'persist'));
    await repo.upsertCheckIn(
      HabitCheckInDraft(habitId: 'persist', localDate: today, value: 1),
    );

    final reopened = LocalHabitRepository(prefs: prefs, clock: clock);
    expect(await reopened.getHabit('persist'), isNotNull);
    expect(await reopened.getCheckInsForHabit('persist'), hasLength(1));
  });

  test('first-run seed uses HabitsSeed when no builder override', () async {
    SharedPreferences.setMockInitialValues({});
    final freshPrefs = await SharedPreferences.getInstance();
    final seeded = LocalHabitRepository(prefs: freshPrefs, clock: clock);
    final habits = await seeded.getHabits();
    expect(habits, isNotEmpty);
    expect(
      habits.map((h) => h.id).toSet(),
      HabitsSeed.demoHabits(
        today: today,
        now: fixedNow,
      ).map((h) => h.id).toSet(),
    );
  });

  test('corrupted document yields empty safe state', () async {
    await prefs.setBool(LocalHabitRepository.initializedKey, true);
    await prefs.setString(LocalHabitRepository.storageKey, '{not-json');
    final broken = LocalHabitRepository(prefs: prefs, clock: clock);
    expect(await broken.getHabits(), isEmpty);
    expect(await broken.getCheckInsForHabit('any'), isEmpty);
  });

  test('corrupted habit/check-in entries are isolated', () async {
    await prefs.setBool(LocalHabitRepository.initializedKey, true);
    await prefs.setString(
      LocalHabitRepository.storageKey,
      jsonEncode({
        'schemaVersion': 1,
        'habits': [
          sampleHabit(id: 'good').toJson(),
          {'id': '', 'name': ''},
        ],
        'checkIns': [
          HabitCheckIn(
            id: 'ci-good',
            habitId: 'good',
            localDate: today,
            value: 1,
            isCompleted: true,
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ).toJson(),
          {'id': 'bad', 'habitId': 'good', 'localDate': 'invalid'},
        ],
      }),
    );

    final loaded = LocalHabitRepository(prefs: prefs, clock: clock);
    expect(await loaded.getHabits(), hasLength(1));
    expect(await loaded.getCheckInsForHabit('good'), hasLength(1));
  });

  test('future check-in rejected', () async {
    await repo.ensureInitialized();
    for (final h in await repo.getHabits()) {
      await repo.deleteHabit(h.id);
    }
    await repo.createHabit(sampleHabit(id: 'future'));

    expect(
      () => repo.upsertCheckIn(
        HabitCheckInDraft(
          habitId: 'future',
          localDate: today.addDays(1),
          value: 1,
        ),
      ),
      throwsArgumentError,
    );
  });
}
