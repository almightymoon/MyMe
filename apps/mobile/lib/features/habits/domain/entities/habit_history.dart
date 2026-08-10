import '../../../../core/domain/value_objects/local_date.dart';
import 'habit_enums.dart';

/// Effective-dated schedule snapshot for a Habit.
///
/// Schedule and target edits create a new revision with [effectiveFrom] set to
/// today (or a future date). Historical check-in interpretation uses the
/// revision applicable on each [LocalDate].
class HabitScheduleRevision {
  const HabitScheduleRevision({
    required this.id,
    required this.habitId,
    required this.effectiveFrom,
    required this.goalType,
    required this.targetValue,
    this.unitLabel,
    required this.frequencyType,
    this.selectedWeekdays = const [],
    this.timesPerWeek,
    required this.createdAt,
  });

  final String id;
  final String habitId;
  final LocalDate effectiveFrom;
  final HabitGoalType goalType;
  final int targetValue;
  final String? unitLabel;
  final HabitFrequencyType frequencyType;
  final List<int> selectedWeekdays;
  final int? timesPerWeek;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'effectiveFrom': effectiveFrom.toIso8601String(),
    'goalType': goalType.name,
    'targetValue': targetValue,
    'unitLabel': unitLabel,
    'frequencyType': frequencyType.name,
    'selectedWeekdays': selectedWeekdays,
    'timesPerWeek': timesPerWeek,
    'createdAt': createdAt.toIso8601String(),
  };

  static HabitScheduleRevision? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final from = LocalDate.tryParse('${json['effectiveFrom']}');
      if (from == null) return null;
      final id = json['id'] as String?;
      final habitId = json['habitId'] as String?;
      final target = (json['targetValue'] as num?)?.toInt();
      if (id == null || habitId == null || target == null || target < 1) {
        return null;
      }
      return HabitScheduleRevision(
        id: id,
        habitId: habitId,
        effectiveFrom: from,
        goalType: HabitGoalType.tryParse(json['goalType'] as String?),
        targetValue: target,
        unitLabel: json['unitLabel'] as String?,
        frequencyType: HabitFrequencyType.tryParse(
          json['frequencyType'] as String?,
        ),
        selectedWeekdays:
            (json['selectedWeekdays'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [],
        timesPerWeek: (json['timesPerWeek'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Status period for pause / archive history.
class HabitStatusPeriod {
  const HabitStatusPeriod({
    required this.id,
    required this.habitId,
    required this.status,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.createdAt,
  });

  final String id;
  final String habitId;
  final HabitStatus status;
  final LocalDate effectiveFrom;

  /// Null means the period is still open.
  final LocalDate? effectiveUntil;
  final DateTime createdAt;

  bool covers(LocalDate date) {
    if (date.isBefore(effectiveFrom)) return false;
    if (effectiveUntil != null && date.isAfter(effectiveUntil!)) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'status': status.name,
    'effectiveFrom': effectiveFrom.toIso8601String(),
    'effectiveUntil': effectiveUntil?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  static HabitStatusPeriod? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final from = LocalDate.tryParse('${json['effectiveFrom']}');
      if (from == null) return null;
      final id = json['id'] as String?;
      final habitId = json['habitId'] as String?;
      if (id == null || habitId == null) return null;
      final untilRaw = json['effectiveUntil'];
      return HabitStatusPeriod(
        id: id,
        habitId: habitId,
        status: HabitStatus.tryParse(json['status'] as String?),
        effectiveFrom: from,
        effectiveUntil: untilRaw == null
            ? null
            : LocalDate.tryParse('$untilRaw'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
