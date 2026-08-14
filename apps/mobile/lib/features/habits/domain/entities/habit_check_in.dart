import '../../../../core/domain/value_objects/local_date.dart';

class HabitCheckIn {
  const HabitCheckIn({
    required this.id,
    required this.habitId,
    required this.localDate,
    required this.value,
    required this.isCompleted,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String habitId;
  final LocalDate localDate;
  final int value;
  final bool isCompleted;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitCheckIn copyWith({
    String? id,
    String? habitId,
    LocalDate? localDate,
    int? value,
    bool? isCompleted,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNote = false,
  }) {
    return HabitCheckIn(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      localDate: localDate ?? this.localDate,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'localDate': localDate.toIso8601String(),
    'value': value,
    'isCompleted': isCompleted,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static HabitCheckIn? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final date = LocalDate.tryParse('${json['localDate']}');
      if (date == null) return null;
      final id = json['id'] as String?;
      final habitId = json['habitId'] as String?;
      if (id == null || habitId == null) return null;
      final value = (json['value'] as num?)?.toInt();
      if (value == null || value < 0) return null;
      return HabitCheckIn(
        id: id,
        habitId: habitId,
        localDate: date,
        value: value,
        isCompleted: json['isCompleted'] == true,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
