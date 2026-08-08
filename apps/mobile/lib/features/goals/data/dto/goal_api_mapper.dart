import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/value_objects/money_minor.dart';

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
      targetAmountMinor: _requireMoney(
        json['targetAmountMinor'],
        'targetAmountMinor',
      ),
      currentAmountMinor: _requireMoney(
        json['currentAmountMinor'],
        'currentAmountMinor',
      ),
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

  /// Body for POST /goals — includes nested milestones for atomic create.
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
        'targetAmountMinor': goal.targetAmountMinor!.toJson(),
      if (goal.currentAmountMinor != null)
        'currentAmountMinor': goal.currentAmountMinor!.toJson(),
      if (goal.currencyCode != null) 'currencyCode': goal.currencyCode,
      'deadline': goal.deadline.toUtc().toIso8601String(),
      'progressPercent': goal.progressPercent,
      'notes': goal.notes,
      if (goal.milestones.isNotEmpty)
        'milestones': [
          for (final m in goal.milestones)
            if (m.title.trim().isNotEmpty) createMilestoneBody(m),
        ],
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
      'targetAmountMinor': goal.targetAmountMinor?.toJson(),
      'currentAmountMinor': goal.currentAmountMinor?.toJson(),
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
    MoneyMinor? currentAmountMinor,
    double? progressPercent,
    String? note,
  }) {
    return {
      'currentAmountMinor': ?currentAmountMinor?.toJson(),
      'progressPercent': ?progressPercent,
      'note': ?note,
    };
  }

  /// Parses `{ goal, createdMilestone }` from POST /milestones.
  static ({Goal goal, GoalMilestone createdMilestone})
  milestoneCreationFromJson(Map<String, dynamic> json) {
    final goalJson = json['goal'];
    final createdJson = json['createdMilestone'];
    if (goalJson is! Map || createdJson is! Map) {
      throw AppException.validation(
        'Milestone create response must include goal and createdMilestone.',
      );
    }
    final goal = goalFromJson(Map<String, dynamic>.from(goalJson));
    final created = milestoneFromJson(Map<String, dynamic>.from(createdJson));
    return (goal: goal, createdMilestone: created);
  }

  /// Null amounts are allowed; non-null corrupt values throw.
  static MoneyMinor? _requireMoney(Object? raw, String field) {
    if (raw == null) return null;
    final parsed = MoneyMinor.fromJson(raw);
    if (parsed == null) {
      throw AppException.validation('Invalid monetary value for $field');
    }
    return parsed;
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
