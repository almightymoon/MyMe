import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';

/// Maps NestJS Goals API JSON ↔ domain entities.
/// Widgets must never parse JSON directly.
class GoalApiMapper {
  const GoalApiMapper._();

  static Goal goalFromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'];
    final milestones = <GoalMilestone>[];
    if (milestonesJson is List) {
      for (final item in milestonesJson) {
        if (item is Map<String, dynamic>) {
          milestones.add(milestoneFromJson(item));
        } else if (item is Map) {
          milestones.add(milestoneFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    milestones.sort((a, b) => a.order.compareTo(b.order));

    return Goal(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: _enumByName(
        GoalCategory.values,
        json['category'] as String?,
        GoalCategory.personalDevelopment,
      ),
      customCategoryName: json['customCategoryName'] as String?,
      priority: _enumByName(
        GoalPriority.values,
        json['priority'] as String?,
        GoalPriority.medium,
      ),
      status: _enumByName(
        GoalStatus.values,
        json['status'] as String?,
        GoalStatus.active,
      ),
      targetAmountMinor: (json['targetAmountMinor'] as num?)?.toInt(),
      currentAmountMinor: (json['currentAmountMinor'] as num?)?.toInt(),
      currencyCode: json['currencyCode'] as String?,
      deadline: _requireDate(json['deadline']),
      createdAt: _requireDate(json['createdAt']),
      updatedAt: _requireDate(json['updatedAt']),
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      milestones: milestones,
      archivedAt: _optionalDate(json['archivedAt']),
    );
  }

  static GoalMilestone milestoneFromJson(Map<String, dynamic> json) {
    return GoalMilestone(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      targetDate: _optionalDate(json['targetDate']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: _optionalDate(json['completedAt']),
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  static List<Goal> goalsFromList(Object? data) {
    if (data is! List) return const [];
    final goals = <Goal>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        goals.add(goalFromJson(item));
      } else if (item is Map) {
        goals.add(goalFromJson(Map<String, dynamic>.from(item)));
      }
    }
    return goals;
  }

  /// Body for POST /goals (server assigns id).
  static Map<String, dynamic> createGoalBody(Goal goal) {
    return {
      'name': goal.name,
      'description': goal.description,
      'category': goal.category.name,
      if (goal.customCategoryName != null)
        'customCategoryName': goal.customCategoryName,
      'priority': goal.priority.name,
      'status': goal.status.name,
      if (goal.targetAmountMinor != null)
        'targetAmountMinor': goal.targetAmountMinor,
      if (goal.currentAmountMinor != null)
        'currentAmountMinor': goal.currentAmountMinor,
      if (goal.currencyCode != null) 'currencyCode': goal.currencyCode,
      'deadline': goal.deadline.toUtc().toIso8601String(),
      'progressPercent': goal.progressPercent,
      'notes': goal.notes,
    };
  }

  /// Body for PATCH /goals/:id.
  static Map<String, dynamic> updateGoalBody(Goal goal) {
    return {
      'name': goal.name,
      'description': goal.description,
      'category': goal.category.name,
      'customCategoryName': goal.customCategoryName,
      'priority': goal.priority.name,
      'status': goal.status.name,
      'targetAmountMinor': goal.targetAmountMinor,
      'currentAmountMinor': goal.currentAmountMinor,
      'currencyCode': goal.currencyCode,
      'deadline': goal.deadline.toUtc().toIso8601String(),
      'progressPercent': goal.progressPercent,
      'notes': goal.notes,
    };
  }

  static Map<String, dynamic> createMilestoneBody(GoalMilestone milestone) {
    return {
      'title': milestone.title,
      if (milestone.description != null) 'description': milestone.description,
      if (milestone.targetDate != null)
        'targetDate': milestone.targetDate!.toUtc().toIso8601String(),
      'order': milestone.order,
    };
  }

  static Map<String, dynamic> updateMilestoneBody(GoalMilestone milestone) {
    return {
      'title': milestone.title,
      'description': milestone.description,
      'targetDate': milestone.targetDate?.toUtc().toIso8601String(),
      'order': milestone.order,
    };
  }

  static Map<String, dynamic> progressBody({
    int? currentAmountMinor,
    double? progressPercent,
    String? note,
  }) {
    return {
      'currentAmountMinor': ?currentAmountMinor,
      'progressPercent': ?progressPercent,
      'note': ?note,
    };
  }

  static DateTime _requireDate(Object? value) {
    return _optionalDate(value) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static DateTime? _optionalDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
