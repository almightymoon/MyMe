class GoalMilestone {
  const GoalMilestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.order,
    this.description,
    this.targetDate,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String goalId;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int order;

  GoalMilestone copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? order,
    bool clearDescription = false,
    bool clearTargetDate = false,
    bool clearCompletedAt = false,
  }) {
    return GoalMilestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'description': description,
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'order': order,
    };
  }

  factory GoalMilestone.fromJson(Map<String, dynamic> json) {
    return GoalMilestone(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      targetDate: _parseDate(json['targetDate']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: _parseDate(json['completedAt']),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
