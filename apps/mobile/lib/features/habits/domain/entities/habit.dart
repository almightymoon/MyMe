import '../../../../core/domain/value_objects/local_date.dart';
import 'habit_enums.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.customCategoryName,
    required this.status,
    required this.goalType,
    required this.targetValue,
    this.unitLabel,
    required this.frequencyType,
    this.selectedWeekdays = const [],
    this.timesPerWeek,
    required this.startDate,
    this.reminderHour,
    this.reminderMinute,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final String? description;
  final HabitCategory category;
  final String? customCategoryName;
  final HabitStatus status;
  final HabitGoalType goalType;

  /// Binary = 1; count = positive integer; duration = minutes.
  final int targetValue;
  final String? unitLabel;
  final HabitFrequencyType frequencyType;

  /// ISO weekdays 1–7 (Mon–Sun). Required for [HabitFrequencyType.selectedWeekdays].
  final List<int> selectedWeekdays;
  final int? timesPerWeek;
  final LocalDate startDate;
  final int? reminderHour;
  final int? reminderMinute;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  String get displayCategory {
    if (category == HabitCategory.custom) {
      return (customCategoryName ?? '').trim().isEmpty
          ? HabitCategory.custom.label
          : customCategoryName!.trim();
    }
    return category.label;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitCategory? category,
    String? customCategoryName,
    HabitStatus? status,
    HabitGoalType? goalType,
    int? targetValue,
    String? unitLabel,
    HabitFrequencyType? frequencyType,
    List<int>? selectedWeekdays,
    int? timesPerWeek,
    LocalDate? startDate,
    int? reminderHour,
    int? reminderMinute,
    String? iconKey,
    String? colorKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    bool clearDescription = false,
    bool clearCustomCategoryName = false,
    bool clearUnitLabel = false,
    bool clearTimesPerWeek = false,
    bool clearReminder = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      category: category ?? this.category,
      customCategoryName: clearCustomCategoryName
          ? null
          : (customCategoryName ?? this.customCategoryName),
      status: status ?? this.status,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      unitLabel: clearUnitLabel ? null : (unitLabel ?? this.unitLabel),
      frequencyType: frequencyType ?? this.frequencyType,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      timesPerWeek: clearTimesPerWeek
          ? null
          : (timesPerWeek ?? this.timesPerWeek),
      startDate: startDate ?? this.startDate,
      reminderHour: clearReminder ? null : (reminderHour ?? this.reminderHour),
      reminderMinute: clearReminder
          ? null
          : (reminderMinute ?? this.reminderMinute),
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'customCategoryName': customCategoryName,
    'status': status.name,
    'goalType': goalType.name,
    'targetValue': targetValue,
    'unitLabel': unitLabel,
    'frequencyType': frequencyType.name,
    'selectedWeekdays': selectedWeekdays,
    'timesPerWeek': timesPerWeek,
    'startDate': startDate.toIso8601String(),
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'iconKey': iconKey,
    'colorKey': colorKey,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'archivedAt': archivedAt?.toIso8601String(),
  };

  static Habit? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final start = LocalDate.tryParse('${json['startDate']}');
      if (start == null) return null;
      final name = (json['name'] as String?)?.trim();
      if (name == null || name.isEmpty) return null;
      final id = json['id'] as String?;
      if (id == null || id.isEmpty) return null;
      final target = (json['targetValue'] as num?)?.toInt();
      if (target == null || target < 1) return null;
      final weekdays =
          (json['selectedWeekdays'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[];
      return Habit(
        id: id,
        name: name,
        description: json['description'] as String?,
        category: HabitCategory.tryParse(json['category'] as String?),
        customCategoryName: json['customCategoryName'] as String?,
        status: HabitStatus.tryParse(json['status'] as String?),
        goalType: HabitGoalType.tryParse(json['goalType'] as String?),
        targetValue: target,
        unitLabel: json['unitLabel'] as String?,
        frequencyType: HabitFrequencyType.tryParse(
          json['frequencyType'] as String?,
        ),
        selectedWeekdays: weekdays,
        timesPerWeek: (json['timesPerWeek'] as num?)?.toInt(),
        startDate: start,
        reminderHour: (json['reminderHour'] as num?)?.toInt(),
        reminderMinute: (json['reminderMinute'] as num?)?.toInt(),
        iconKey: (json['iconKey'] as String?) ?? 'check',
        colorKey: (json['colorKey'] as String?) ?? 'ember',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        archivedAt: json['archivedAt'] == null
            ? null
            : DateTime.parse(json['archivedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
