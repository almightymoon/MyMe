import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_check_in.dart';
import '../../domain/entities/habit_enums.dart';
import '../../domain/entities/habit_progress.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_progress_service.dart';
import '../../domain/services/habit_schedule_service.dart';
import '../seed/habits_seed.dart';

/// Local JSON persistence for Habits (SharedPreferences).
///
/// Schema:
/// ```json
/// {
///   "schemaVersion": 1,
///   "habits": [ /* Habit.toJson() */ ],
///   "checkIns": [ /* HabitCheckIn.toJson() */ ]
/// }
/// ```
///
/// Flag `memy_habits_initialized_v1` ensures demo seed runs only once.
/// Deleting all Habits does not reseed.
class LocalHabitRepository implements HabitRepository {
  LocalHabitRepository({
    required this.prefs,
    AppClock? clock,
    HabitProgressService? progressService,
    this.seedHabitsBuilder,
    this.seedCheckInsBuilder,
    this.idGenerator,
  }) : _clock = clock ?? const SystemAppClock(),
       _progress =
           progressService ??
           HabitProgressService(scheduleService: const HabitScheduleService());

  static const int schemaVersion = 1;
  static const String storageKey = 'memy_habits_v1';
  static const String initializedKey = 'memy_habits_initialized_v1';

  final SharedPreferences prefs;
  final AppClock _clock;
  final HabitProgressService _progress;
  final List<Habit> Function(LocalDate today, DateTime now)? seedHabitsBuilder;
  final List<HabitCheckIn> Function(LocalDate today, DateTime now)?
  seedCheckInsBuilder;
  final String Function()? idGenerator;

  final _habitController = StreamController<List<Habit>>.broadcast();
  final _checkInController = StreamController<List<HabitCheckIn>>.broadcast();
  Future<void>? _initFuture;

  List<Habit> _habits = const [];
  List<HabitCheckIn> _checkIns = const [];

  void dispose() {
    _habitController.close();
    _checkInController.close();
  }

  Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    final initialized = prefs.getBool(initializedKey) ?? false;
    final now = _clock.now();
    final today = LocalDate.fromDateTime(now);
    if (!initialized) {
      _habits = List<Habit>.unmodifiable(
        seedHabitsBuilder?.call(today, now) ??
            HabitsSeed.demoHabits(today: today, now: now),
      );
      _checkIns = List<HabitCheckIn>.unmodifiable(
        seedCheckInsBuilder?.call(today, now) ??
            HabitsSeed.demoCheckIns(today: today, now: now),
      );
      await _persist();
      await prefs.setBool(initializedKey, true);
      return;
    }
    _readFromDisk();
  }

  void _readFromDisk() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _habits = const [];
      _checkIns = const [];
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _habits = const [];
        _checkIns = const [];
        return;
      }
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version != schemaVersion && version != 0) {
        _habits = const [];
        _checkIns = const [];
        return;
      }

      final habits = <Habit>[];
      final habitList = map['habits'];
      if (habitList is List) {
        for (final item in habitList) {
          final parsed = item is Map<String, dynamic>
              ? Habit.tryFromJson(item)
              : item is Map
              ? Habit.tryFromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) habits.add(parsed);
        }
      }

      final checkIns = <HabitCheckIn>[];
      final checkInList = map['checkIns'];
      if (checkInList is List) {
        for (final item in checkInList) {
          final parsed = item is Map<String, dynamic>
              ? HabitCheckIn.tryFromJson(item)
              : item is Map
              ? HabitCheckIn.tryFromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) checkIns.add(parsed);
        }
      }

      // Deduplicate check-ins by habitId+date (keep latest updatedAt).
      final byKey = <String, HabitCheckIn>{};
      for (final c in checkIns) {
        final key = '${c.habitId}|${c.localDate}';
        final prev = byKey[key];
        if (prev == null || c.updatedAt.isAfter(prev.updatedAt)) {
          byKey[key] = c;
        }
      }

      _habits = List<Habit>.unmodifiable(habits);
      _checkIns = List<HabitCheckIn>.unmodifiable(byKey.values.toList());
    } catch (_) {
      // Malformed blob → empty-safe; do not wipe initialized flag.
      _habits = const [];
      _checkIns = const [];
    }
  }

  Future<void> _persist() async {
    final payload = jsonEncode({
      'schemaVersion': schemaVersion,
      'habits': _habits.map((h) => h.toJson()).toList(),
      'checkIns': _checkIns.map((c) => c.toJson()).toList(),
    });
    await prefs.setString(storageKey, payload);
    _habitController.add(List.unmodifiable(_habits));
    _checkInController.add(List.unmodifiable(_checkIns));
  }

  LocalDate get _today => LocalDate.fromDateTime(_clock.now());

  String _newId() =>
      idGenerator?.call() ?? 'habit_${_clock.now().microsecondsSinceEpoch}';

  @override
  Stream<List<Habit>> watchHabits() async* {
    await ensureInitialized();
    yield List.unmodifiable(_habits);
    yield* _habitController.stream;
  }

  @override
  Stream<List<HabitCheckIn>> watchCheckIns() async* {
    await ensureInitialized();
    yield List.unmodifiable(_checkIns);
    yield* _checkInController.stream;
  }

  @override
  Future<List<Habit>> getHabits() async {
    await ensureInitialized();
    return List.unmodifiable(_habits);
  }

  @override
  Future<Habit?> getHabit(String id) async {
    await ensureInitialized();
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    await ensureInitialized();
    final withId = habit.id.isEmpty ? habit.copyWith(id: _newId()) : habit;
    _habits = [..._habits, withId];
    await _persist();
    return withId;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await ensureInitialized();
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx < 0) throw StateError('Habit not found: ${habit.id}');
    final next = [..._habits];
    next[idx] = habit;
    _habits = next;
    await _persist();
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
    await ensureInitialized();
    _habits = _habits.where((h) => h.id != id).toList();
    _checkIns = _checkIns.where((c) => c.habitId != id).toList();
    await _persist();
  }

  @override
  Future<List<HabitCheckIn>> getCheckInsForHabit(String habitId) async {
    await ensureInitialized();
    return _checkIns.where((c) => c.habitId == habitId).toList(growable: false);
  }

  @override
  Future<List<HabitCheckIn>> getCheckInsForRange({
    required LocalDate start,
    required LocalDate endInclusive,
  }) async {
    await ensureInitialized();
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
    await ensureInitialized();
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
      await _persist();
      return updated;
    }
    final created = HabitCheckIn(
      id:
          idGenerator?.call() ??
          'ci_${draft.habitId}_${draft.localDate.toIso8601String()}',
      habitId: draft.habitId,
      localDate: draft.localDate,
      value: value,
      isCompleted: completed,
      note: draft.note,
      createdAt: now,
      updatedAt: now,
    );
    _checkIns = [..._checkIns, created];
    await _persist();
    return created;
  }

  @override
  Future<void> removeCheckIn({
    required String habitId,
    required LocalDate localDate,
  }) async {
    await ensureInitialized();
    _checkIns = _checkIns
        .where((c) => !(c.habitId == habitId && c.localDate == localDate))
        .toList();
    await _persist();
  }

  @override
  Future<List<HabitTodayItem>> getTodayItems(LocalDate date) async {
    await ensureInitialized();
    return _progress
        .overview(habits: _habits, checkIns: _checkIns, date: date)
        .items;
  }

  @override
  Future<HabitsOverviewSummary> getOverview(LocalDate date) async {
    await ensureInitialized();
    return _progress.overview(habits: _habits, checkIns: _checkIns, date: date);
  }

  @override
  Future<void> refresh() async {
    await ensureInitialized();
    _readFromDisk();
    _habitController.add(List.unmodifiable(_habits));
    _checkInController.add(List.unmodifiable(_checkIns));
  }
}
