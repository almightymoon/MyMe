import 'dart:async';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_check_in.dart';
import '../../domain/entities/habit_enums.dart';
import '../../domain/entities/habit_history.dart';
import '../../domain/entities/habit_progress.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_progress_service.dart';
import '../../domain/services/habit_schedule_service.dart';
import '../seed/habits_seed.dart';

class FakeHabitRepository implements HabitRepository {
  FakeHabitRepository({
    List<Habit>? initialHabits,
    List<HabitCheckIn>? initialCheckIns,
    AppClock? clock,
    HabitProgressService? progressService,
    this.empty = false,
    this.forceFailure = false,
  }) : _clock = clock ?? const SystemAppClock(),
       _progress =
           progressService ??
           HabitProgressService(scheduleService: const HabitScheduleService()) {
    final now = _clock.now();
    final today = LocalDate.fromDateTime(now);
    if (empty) {
      _habits = [];
      _checkIns = [];
    } else {
      _habits = List<Habit>.from(
        initialHabits ?? HabitsSeed.demoHabits(today: today, now: now),
      );
      _checkIns = List<HabitCheckIn>.from(
        initialCheckIns ?? HabitsSeed.demoCheckIns(today: today, now: now),
      );
    }
  }

  final AppClock _clock;
  final HabitProgressService _progress;
  final bool empty;
  bool forceFailure;

  final _habitController = StreamController<List<Habit>>.broadcast();
  final _checkInController = StreamController<List<HabitCheckIn>>.broadcast();

  List<Habit> _habits = [];
  List<HabitCheckIn> _checkIns = [];

  void dispose() {
    _habitController.close();
    _checkInController.close();
  }

  void _emit() {
    _habitController.add(List.unmodifiable(_habits));
    _checkInController.add(List.unmodifiable(_checkIns));
  }

  Future<void> _guard() async {
    if (forceFailure) {
      throw StateError('FakeHabitRepository failure mode enabled');
    }
  }

  LocalDate get _today => LocalDate.fromDateTime(_clock.now());

  @override
  Stream<List<Habit>> watchHabits() async* {
    await _guard();
    yield List.unmodifiable(_habits);
    yield* _habitController.stream;
  }

  @override
  Stream<List<HabitCheckIn>> watchCheckIns() async* {
    await _guard();
    yield List.unmodifiable(_checkIns);
    yield* _checkInController.stream;
  }

  @override
  Future<List<Habit>> getHabits() async {
    await _guard();
    return List.unmodifiable(_habits);
  }

  @override
  Future<Habit?> getHabit(String id) async {
    await _guard();
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    await _guard();
    _habits = [..._habits, habit];
    _emit();
    return habit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await _guard();
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx < 0) throw StateError('Habit not found: ${habit.id}');
    final next = [..._habits];
    next[idx] = habit;
    _habits = next;
    _emit();
    return habit;
  }

  Future<Habit> _setStatus(String id, HabitStatus status) async {
    final existing = await getHabit(id);
    if (existing == null) throw StateError('Habit not found: $id');
    final now = _clock.now();
    final updated = existing.copyWith(
      status: status,
      updatedAt: now,
      archivedAt: status == HabitStatus.archived ? now : existing.archivedAt,
      clearArchivedAt: status != HabitStatus.archived,
    );
    return updateHabit(updated);
  }

  @override
  Future<Habit> pauseHabit(String id) => _setStatus(id, HabitStatus.paused);

  @override
  Future<Habit> resumeHabit(String id) => _setStatus(id, HabitStatus.active);

  @override
  Future<Habit> archiveHabit(String id) => _setStatus(id, HabitStatus.archived);

  @override
  Future<Habit> restoreHabit(String id) => _setStatus(id, HabitStatus.active);

  @override
  Future<void> deleteHabit(String id) async {
    await _guard();
    _habits = _habits.where((h) => h.id != id).toList();
    _checkIns = _checkIns.where((c) => c.habitId != id).toList();
    _emit();
  }

  @override
  Future<List<HabitCheckIn>> getCheckInsForHabit(String habitId) async {
    await _guard();
    return _checkIns.where((c) => c.habitId == habitId).toList(growable: false);
  }

  @override
  Future<List<HabitCheckIn>> getCheckInsForRange({
    required LocalDate start,
    required LocalDate endInclusive,
  }) async {
    await _guard();
    return _checkIns
        .where(
          (c) =>
              !c.localDate.isBefore(start) &&
              !c.localDate.isAfter(endInclusive),
        )
        .toList(growable: false);
  }

  @override
  Future<HabitCheckIn> upsertCheckIn(HabitCheckInDraft draft) async {
    await _guard();
    final today = _today;
    if (draft.localDate.isAfter(today)) {
      throw ArgumentError('Future check-ins are not allowed');
    }
    final habit = await getHabit(draft.habitId);
    if (habit == null) throw StateError('Habit not found: ${draft.habitId}');
    final value = normalizedCheckInValue(habit, draft.value);
    final completed = isHabitValueCompleted(habit, value);
    final now = _clock.now();
    final existingIndex = _checkIns.indexWhere(
      (c) => c.habitId == draft.habitId && c.localDate == draft.localDate,
    );
    if (existingIndex >= 0) {
      final prev = _checkIns[existingIndex];
      final updated = prev.copyWith(
        value: value,
        isCompleted: completed,
        note: draft.note,
        updatedAt: now,
        clearNote: draft.note == null,
      );
      final next = [..._checkIns];
      next[existingIndex] = updated;
      _checkIns = next;
      _emit();
      return updated;
    }
    final created = HabitCheckIn(
      id: 'ci_${draft.habitId}_${draft.localDate.toIso8601String()}',
      habitId: draft.habitId,
      localDate: draft.localDate,
      value: value,
      isCompleted: completed,
      note: draft.note,
      createdAt: now,
      updatedAt: now,
    );
    _checkIns = [..._checkIns, created];
    _emit();
    return created;
  }

  @override
  Future<void> removeCheckIn({
    required String habitId,
    required LocalDate localDate,
  }) async {
    await _guard();
    _checkIns = _checkIns
        .where((c) => !(c.habitId == habitId && c.localDate == localDate))
        .toList();
    _emit();
  }

  @override
  Future<List<HabitTodayItem>> getTodayItems(LocalDate date) async {
    await _guard();
    return _progress
        .overview(habits: _habits, checkIns: _checkIns, date: date)
        .items;
  }

  @override
  Future<HabitsOverviewSummary> getOverview(LocalDate date) async {
    await _guard();
    return _progress.overview(habits: _habits, checkIns: _checkIns, date: date);
  }

  @override
  Future<void> refresh() async {
    await _guard();
    _emit();
  }

  /// The Fake repository has no real history store — it synthesizes a
  /// single revision from the Habit's current fields on each call so
  /// callers depending on [HabitRepository]'s history API keep working in
  /// demo mode without persisting anything extra.
  @override
  Future<List<HabitScheduleRevision>> getScheduleRevisions(
    String habitId,
  ) async {
    await _guard();
    final habit = await getHabit(habitId);
    if (habit == null) return const [];
    return [
      HabitScheduleRevision(
        id: 'fake_revision_$habitId',
        habitId: habitId,
        effectiveFrom: habit.startDate,
        goalType: habit.goalType,
        targetValue: habit.targetValue,
        unitLabel: habit.unitLabel,
        frequencyType: habit.frequencyType,
        selectedWeekdays: habit.selectedWeekdays,
        timesPerWeek: habit.timesPerWeek,
        createdAt: habit.createdAt,
      ),
    ];
  }

  @override
  Future<List<HabitStatusPeriod>> getStatusPeriods(String habitId) async {
    await _guard();
    final habit = await getHabit(habitId);
    if (habit == null) return const [];
    return [
      HabitStatusPeriod(
        id: 'fake_period_$habitId',
        habitId: habitId,
        status: habit.status,
        effectiveFrom: habit.startDate,
        createdAt: habit.createdAt,
      ),
    ];
  }
}
