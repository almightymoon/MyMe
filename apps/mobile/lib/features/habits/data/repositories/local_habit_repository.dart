import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

/// Local JSON persistence for Habits (SharedPreferences).
///
/// Schema (v2):
/// ```json
/// {
///   "schemaVersion": 2,
///   "habits": [ /* Habit.toJson() */ ],
///   "checkIns": [ /* HabitCheckIn.toJson() */ ],
///   "scheduleRevisions": [ /* HabitScheduleRevision.toJson() */ ],
///   "statusPeriods": [ /* HabitStatusPeriod.toJson() */ ]
/// }
/// ```
///
/// v1 → v2 migration: any Habit found without schedule-revision or
/// status-period history (i.e. every Habit persisted before history
/// tracking existed) is backfilled with one initial [HabitScheduleRevision]
/// and one open [HabitStatusPeriod] synthesized from its *current* fields,
/// effective from its `startDate`. This runs once per load and re-persists
/// immediately so it only happens the first time a v1 document is opened.
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

  static const int schemaVersion = 2;
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
  List<HabitScheduleRevision> _scheduleRevisions = const [];
  List<HabitStatusPeriod> _statusPeriods = const [];

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
      _ensureHistoryForAllHabits();
      await _persist();
      await prefs.setBool(initializedKey, true);
      return;
    }
    _readFromDisk();
    if (_ensureHistoryForAllHabits()) {
      await _persist();
    }
  }

  void _readFromDisk() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _habits = const [];
      _checkIns = const [];
      _scheduleRevisions = const [];
      _statusPeriods = const [];
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _habits = const [];
        _checkIns = const [];
        _scheduleRevisions = const [];
        _statusPeriods = const [];
        return;
      }
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version > schemaVersion) {
        // Unknown future format — be safe rather than misinterpret it.
        _habits = const [];
        _checkIns = const [];
        _scheduleRevisions = const [];
        _statusPeriods = const [];
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

      final revisions = <HabitScheduleRevision>[];
      final revisionList = map['scheduleRevisions'];
      if (revisionList is List) {
        for (final item in revisionList) {
          final parsed = item is Map<String, dynamic>
              ? HabitScheduleRevision.tryFromJson(item)
              : item is Map
              ? HabitScheduleRevision.tryFromJson(
                  Map<String, dynamic>.from(item),
                )
              : null;
          if (parsed != null) revisions.add(parsed);
        }
      }

      final periods = <HabitStatusPeriod>[];
      final periodList = map['statusPeriods'];
      if (periodList is List) {
        for (final item in periodList) {
          final parsed = item is Map<String, dynamic>
              ? HabitStatusPeriod.tryFromJson(item)
              : item is Map
              ? HabitStatusPeriod.tryFromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) periods.add(parsed);
        }
      }

      _habits = List<Habit>.unmodifiable(habits);
      _checkIns = List<HabitCheckIn>.unmodifiable(byKey.values.toList());
      _scheduleRevisions = List<HabitScheduleRevision>.unmodifiable(revisions);
      _statusPeriods = List<HabitStatusPeriod>.unmodifiable(periods);
    } catch (_) {
      // Malformed blob → empty-safe; do not wipe initialized flag.
      _habits = const [];
      _checkIns = const [];
      _scheduleRevisions = const [];
      _statusPeriods = const [];
    }
  }

  /// Backfills an initial [HabitScheduleRevision] / open [HabitStatusPeriod]
  /// for any Habit that has none (v1 data, or any other gap). Returns true
  /// when it added anything so the caller knows to re-persist.
  bool _ensureHistoryForAllHabits() {
    final revisionHabitIds = _scheduleRevisions.map((r) => r.habitId).toSet();
    final periodHabitIds = _statusPeriods.map((p) => p.habitId).toSet();
    final newRevisions = <HabitScheduleRevision>[];
    final newPeriods = <HabitStatusPeriod>[];
    for (final habit in _habits) {
      if (!revisionHabitIds.contains(habit.id)) {
        newRevisions.add(_initialRevisionFor(habit));
      }
      if (!periodHabitIds.contains(habit.id)) {
        newPeriods.add(_initialPeriodFor(habit));
      }
    }
    if (newRevisions.isEmpty && newPeriods.isEmpty) return false;
    if (newRevisions.isNotEmpty) {
      _scheduleRevisions = [..._scheduleRevisions, ...newRevisions];
    }
    if (newPeriods.isNotEmpty) {
      _statusPeriods = [..._statusPeriods, ...newPeriods];
    }
    return true;
  }

  HabitScheduleRevision _initialRevisionFor(Habit habit) {
    return HabitScheduleRevision(
      id: _newId(),
      habitId: habit.id,
      effectiveFrom: habit.startDate,
      goalType: habit.goalType,
      targetValue: habit.targetValue,
      unitLabel: habit.unitLabel,
      frequencyType: habit.frequencyType,
      selectedWeekdays: habit.selectedWeekdays,
      timesPerWeek: habit.timesPerWeek,
      createdAt: habit.createdAt,
    );
  }

  HabitStatusPeriod _initialPeriodFor(Habit habit) {
    return HabitStatusPeriod(
      id: _newId(),
      habitId: habit.id,
      status: habit.status,
      effectiveFrom: habit.startDate,
      createdAt: habit.createdAt,
    );
  }

  Future<void> _persist() async {
    final payload = jsonEncode({
      'schemaVersion': schemaVersion,
      'habits': _habits.map((h) => h.toJson()).toList(),
      'checkIns': _checkIns.map((c) => c.toJson()).toList(),
      'scheduleRevisions': _scheduleRevisions.map((r) => r.toJson()).toList(),
      'statusPeriods': _statusPeriods.map((p) => p.toJson()).toList(),
    });
    await prefs.setString(storageKey, payload);
    _habitController.add(List.unmodifiable(_habits));
    _checkInController.add(List.unmodifiable(_checkIns));
  }

  LocalDate get _today => LocalDate.fromDateTime(_clock.now());

  String _newId() =>
      idGenerator?.call() ?? 'habit_${_clock.now().microsecondsSinceEpoch}';

  bool _scheduleFieldsEqual(Habit a, Habit b) {
    if (a.goalType != b.goalType) return false;
    if (a.targetValue != b.targetValue) return false;
    if (a.unitLabel != b.unitLabel) return false;
    if (a.frequencyType != b.frequencyType) return false;
    if (a.timesPerWeek != b.timesPerWeek) return false;
    if (a.selectedWeekdays.length != b.selectedWeekdays.length) return false;
    for (var i = 0; i < a.selectedWeekdays.length; i++) {
      if (a.selectedWeekdays[i] != b.selectedWeekdays[i]) return false;
    }
    return true;
  }

  /// Appends a new revision effective today when [updated]'s schedule/target
  /// differs from [previous]. Historical dates keep resolving against prior
  /// revisions — this never rewrites the past.
  void _appendRevisionIfScheduleChanged(Habit previous, Habit updated) {
    if (_scheduleFieldsEqual(previous, updated)) return;
    _scheduleRevisions = [
      ..._scheduleRevisions,
      HabitScheduleRevision(
        id: _newId(),
        habitId: updated.id,
        effectiveFrom: _today,
        goalType: updated.goalType,
        targetValue: updated.targetValue,
        unitLabel: updated.unitLabel,
        frequencyType: updated.frequencyType,
        selectedWeekdays: updated.selectedWeekdays,
        timesPerWeek: updated.timesPerWeek,
        createdAt: _clock.now(),
      ),
    ];
  }

  /// Closes the open status period (if any) and opens a new one effective
  /// today. No-op when [habitId]'s open period already has [newStatus].
  void _transitionStatusPeriod(String habitId, HabitStatus newStatus) {
    final today = _today;
    final openIndex = _statusPeriods.indexWhere(
      (p) => p.habitId == habitId && p.effectiveUntil == null,
    );
    final next = [..._statusPeriods];
    if (openIndex >= 0) {
      final open = next[openIndex];
      if (open.status == newStatus) return;
      next[openIndex] = HabitStatusPeriod(
        id: open.id,
        habitId: open.habitId,
        status: open.status,
        effectiveFrom: open.effectiveFrom,
        effectiveUntil: today.addDays(-1),
        createdAt: open.createdAt,
      );
    }
    next.add(
      HabitStatusPeriod(
        id: _newId(),
        habitId: habitId,
        status: newStatus,
        effectiveFrom: today,
        createdAt: _clock.now(),
      ),
    );
    _statusPeriods = next;
  }

  Map<String, List<HabitScheduleRevision>> get _revisionsByHabitId {
    final map = <String, List<HabitScheduleRevision>>{};
    for (final r in _scheduleRevisions) {
      (map[r.habitId] ??= <HabitScheduleRevision>[]).add(r);
    }
    return map;
  }

  Map<String, List<HabitStatusPeriod>> get _statusPeriodsByHabitId {
    final map = <String, List<HabitStatusPeriod>>{};
    for (final p in _statusPeriods) {
      (map[p.habitId] ??= <HabitStatusPeriod>[]).add(p);
    }
    return map;
  }

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
    _scheduleRevisions = [..._scheduleRevisions, _initialRevisionFor(withId)];
    _statusPeriods = [..._statusPeriods, _initialPeriodFor(withId)];
    await _persist();
    return withId;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await ensureInitialized();
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx < 0) throw StateError('Habit not found: ${habit.id}');
    final previous = _habits[idx];
    final next = [..._habits];
    next[idx] = habit;
    _habits = next;
    _appendRevisionIfScheduleChanged(previous, habit);
    if (previous.status != habit.status) {
      _transitionStatusPeriod(habit.id, habit.status);
    }
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
    _scheduleRevisions = _scheduleRevisions
        .where((r) => r.habitId != id)
        .toList();
    _statusPeriods = _statusPeriods.where((p) => p.habitId != id).toList();
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
  Future<List<HabitScheduleRevision>> getScheduleRevisions(
    String habitId,
  ) async {
    await ensureInitialized();
    return _scheduleRevisions
        .where((r) => r.habitId == habitId)
        .toList(growable: false);
  }

  @override
  Future<List<HabitStatusPeriod>> getStatusPeriods(String habitId) async {
    await ensureInitialized();
    return _statusPeriods
        .where((p) => p.habitId == habitId)
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

    // Resolve goal/target as of the check-in's date (not the habit's current
    // fields) so a later schedule/target edit never rewrites the completion
    // outcome of a backfilled past check-in.
    final revisions = _revisionsByHabitId[habit.id] ?? const [];
    final fields = _progress.scheduleService.fieldsOn(
      habit,
      revisions,
      draft.localDate,
    );
    final value = normalizeValueFor(fields.goalType, draft.value);
    final completed = isValueCompletedFor(
      fields.goalType,
      fields.targetValue,
      value,
    );
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
        .overview(
          habits: _habits,
          checkIns: _checkIns,
          date: date,
          revisionsByHabitId: _revisionsByHabitId,
          statusPeriodsByHabitId: _statusPeriodsByHabitId,
        )
        .items;
  }

  @override
  Future<HabitsOverviewSummary> getOverview(LocalDate date) async {
    await ensureInitialized();
    return _progress.overview(
      habits: _habits,
      checkIns: _checkIns,
      date: date,
      revisionsByHabitId: _revisionsByHabitId,
      statusPeriodsByHabitId: _statusPeriodsByHabitId,
    );
  }

  @override
  Future<void> refresh() async {
    await ensureInitialized();
    _readFromDisk();
    if (_ensureHistoryForAllHabits()) {
      await _persist();
    } else {
      _habitController.add(List.unmodifiable(_habits));
      _checkInController.add(List.unmodifiable(_checkIns));
    }
  }

  /// Wipes all local habits, check-ins, and history. Does not reseed.
  Future<void> clearAllLocalData() async {
    await ensureInitialized();
    _habits = const [];
    _checkIns = const [];
    _scheduleRevisions = const [];
    _statusPeriods = const [];
    await _persist();
  }
}
