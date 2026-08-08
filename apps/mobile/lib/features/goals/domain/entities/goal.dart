import '../value_objects/money_minor.dart';
import 'goal_enums.dart';
import 'goal_milestone.dart';

class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.priority,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercent,
    this.description = '',
    this.customCategoryName,
    this.targetAmountMinor,
    this.currentAmountMinor,
    this.currencyCode,
    this.notes = '',
    this.milestones = const [],
    this.archivedAt,
  });

  final String id;
  final String name;
  final String description;
  final GoalCategory category;
  final String? customCategoryName;
  final GoalPriority priority;
  final GoalStatus status;
  final MoneyMinor? targetAmountMinor;
  final MoneyMinor? currentAmountMinor;
  final String? currencyCode;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progressPercent;
  final String notes;
  final List<GoalMilestone> milestones;
  final DateTime? archivedAt;

  bool get isFinancial =>
      category == GoalCategory.financial || targetAmountMinor != null;

  bool get hasAmountFields =>
      targetAmountMinor != null || currentAmountMinor != null;

  String get displayCategory {
    if (category == GoalCategory.custom) {
      final custom = customCategoryName?.trim();
      if (custom != null && custom.isNotEmpty) return custom;
    }
    return category.label;
  }

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    GoalCategory? category,
    String? customCategoryName,
    GoalPriority? priority,
    GoalStatus? status,
    MoneyMinor? targetAmountMinor,
    MoneyMinor? currentAmountMinor,
    String? currencyCode,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? progressPercent,
    String? notes,
    List<GoalMilestone>? milestones,
    DateTime? archivedAt,
    bool clearCustomCategoryName = false,
    bool clearTargetAmountMinor = false,
    bool clearCurrentAmountMinor = false,
    bool clearCurrencyCode = false,
    bool clearArchivedAt = false,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      customCategoryName: clearCustomCategoryName
          ? null
          : (customCategoryName ?? this.customCategoryName),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetAmountMinor: clearTargetAmountMinor
          ? null
          : (targetAmountMinor ?? this.targetAmountMinor),
      currentAmountMinor: clearCurrentAmountMinor
          ? null
          : (currentAmountMinor ?? this.currentAmountMinor),
      currencyCode: clearCurrencyCode
          ? null
          : (currencyCode ?? this.currencyCode),
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progressPercent: progressPercent ?? this.progressPercent,
      notes: notes ?? this.notes,
      milestones: milestones ?? this.milestones,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'customCategoryName': customCategoryName,
      'priority': priority.name,
      'status': status.name,
      'targetAmountMinor': targetAmountMinor?.toJson(),
      'currentAmountMinor': currentAmountMinor?.toJson(),
      'currencyCode': currencyCode,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'progressPercent': progressPercent,
      'notes': notes,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  /// Never throws — corrupt/legacy amount values are dropped (`null`)
  /// rather than crashing local storage reads. [MoneyMinor.fromJson]
  /// transparently accepts legacy `int`/`num` amounts alongside the current
  /// decimal-string wire format.
  factory Goal.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'];
    final milestones = <GoalMilestone>[];
    if (milestonesJson is List) {
      for (final item in milestonesJson) {
        if (item is Map<String, dynamic>) {
          milestones.add(GoalMilestone.fromJson(item));
        } else if (item is Map) {
          milestones.add(
            GoalMilestone.fromJson(Map<String, dynamic>.from(item)),
          );
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
      targetAmountMinor: MoneyMinor.fromJson(json['targetAmountMinor']),
      currentAmountMinor: MoneyMinor.fromJson(json['currentAmountMinor']),
      currencyCode: json['currencyCode'] as String?,
      deadline:
          DateTime.tryParse(json['deadline'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
      milestones: milestones,
      archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? ''),
    );
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
