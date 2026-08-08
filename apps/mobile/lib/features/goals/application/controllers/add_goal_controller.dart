import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/services/goal_progress_calculator.dart';
import '../../domain/services/money_format.dart';
import '../../domain/value_objects/money_minor.dart';
import '../providers/goal_providers.dart';
import '../../../../core/errors/app_exception.dart';

class AddGoalFormState {
  const AddGoalFormState({
    this.name = '',
    this.description = '',
    this.category = GoalCategory.financial,
    this.customCategoryName = '',
    this.priority = GoalPriority.medium,
    this.targetAmountText = '',
    this.currentAmountText = '',
    this.currencyCode = MoneyFormat.defaultCurrencyCode,
    this.deadline,
    this.notes = '',
    this.milestoneTitles = const [''],
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final String name;
  final String description;
  final GoalCategory category;
  final String customCategoryName;
  final GoalPriority priority;
  final String targetAmountText;
  final String currentAmountText;
  final String currencyCode;
  final DateTime? deadline;
  final String notes;
  final List<String> milestoneTitles;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  AddGoalFormState copyWith({
    String? name,
    String? description,
    GoalCategory? category,
    String? customCategoryName,
    GoalPriority? priority,
    String? targetAmountText,
    String? currentAmountText,
    String? currencyCode,
    DateTime? deadline,
    String? notes,
    List<String>? milestoneTitles,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearError = false,
    bool clearDeadline = false,
  }) {
    return AddGoalFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      customCategoryName: customCategoryName ?? this.customCategoryName,
      priority: priority ?? this.priority,
      targetAmountText: targetAmountText ?? this.targetAmountText,
      currentAmountText: currentAmountText ?? this.currentAmountText,
      currencyCode: currencyCode ?? this.currencyCode,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      notes: notes ?? this.notes,
      milestoneTitles: milestoneTitles ?? this.milestoneTitles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class AddGoalController extends StateNotifier<AddGoalFormState> {
  AddGoalController(this._ref) : super(const AddGoalFormState());

  final Ref _ref;

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setCategory(GoalCategory value) =>
      state = state.copyWith(category: value);
  void setCustomCategoryName(String value) =>
      state = state.copyWith(customCategoryName: value);
  void setPriority(GoalPriority value) =>
      state = state.copyWith(priority: value);
  void setTargetAmountText(String value) =>
      state = state.copyWith(targetAmountText: value);
  void setCurrentAmountText(String value) =>
      state = state.copyWith(currentAmountText: value);
  void setCurrencyCode(String value) =>
      state = state.copyWith(currencyCode: value.toUpperCase());
  void setDeadline(DateTime? value) => state = state.copyWith(deadline: value);
  void setNotes(String value) => state = state.copyWith(notes: value);

  void setMilestoneTitle(int index, String value) {
    final next = [...state.milestoneTitles];
    if (index < 0 || index >= next.length) return;
    next[index] = value;
    state = state.copyWith(milestoneTitles: next);
  }

  void addMilestoneField() {
    state = state.copyWith(milestoneTitles: [...state.milestoneTitles, '']);
  }

  void removeMilestoneField(int index) {
    if (state.milestoneTitles.length <= 1) {
      state = state.copyWith(milestoneTitles: const ['']);
      return;
    }
    final next = [...state.milestoneTitles]..removeAt(index);
    state = state.copyWith(milestoneTitles: next);
  }

  Map<String, String> validate({DateTime? asOf}) {
    final errors = <String, String>{};
    final today = DateTime(
      (asOf ?? DateTime.now()).year,
      (asOf ?? DateTime.now()).month,
      (asOf ?? DateTime.now()).day,
    );

    if (state.name.trim().isEmpty) {
      errors['name'] = 'Goal name is required';
    }
    if (state.deadline == null) {
      errors['deadline'] = 'Deadline is required';
    } else {
      final deadline = DateTime(
        state.deadline!.year,
        state.deadline!.month,
        state.deadline!.day,
      );
      if (deadline.isBefore(today)) {
        errors['deadline'] = 'Deadline cannot be in the past';
      }
    }
    if (state.category == GoalCategory.custom &&
        state.customCategoryName.trim().isEmpty) {
      errors['customCategoryName'] = 'Enter a custom category name';
    }

    MoneyMinor? targetMinor;
    MoneyMinor? currentMinor;
    try {
      targetMinor = MoneyFormat.parseMajorToMinor(state.targetAmountText);
    } on FormatException {
      errors['targetAmount'] = 'Enter a valid target amount';
    }
    try {
      currentMinor = MoneyFormat.parseMajorToMinor(state.currentAmountText);
    } on FormatException {
      errors['currentAmount'] = 'Enter a valid current amount';
    }

    if (targetMinor != null && !targetMinor.isPositive) {
      errors['targetAmount'] = 'Target amount must be positive';
    }
    // currentMinor is a MoneyMinor, which cannot be negative by construction.
    if ((targetMinor != null || currentMinor != null) &&
        state.currencyCode.trim().isEmpty) {
      errors['currencyCode'] = 'Currency is required when an amount is set';
    }
    if (targetMinor != null &&
        currentMinor != null &&
        currentMinor > targetMinor) {
      errors['currentAmount'] =
          'Current amount exceeds target — lower it or mark the goal complete after save';
    }

    return errors;
  }

  /// Returns created goal id, or null on validation/submit failure.
  Future<String?> submit() async {
    if (state.isSubmitting) return null;

    final errors = validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      fieldErrors: const {},
      clearError: true,
    );

    try {
      final uuid = _ref.read(uuidProvider);
      final now = DateTime.now();
      final id = uuid.v4();
      final targetMinor = MoneyFormat.parseMajorToMinor(state.targetAmountText);
      final currentMinor = MoneyFormat.parseMajorToMinor(
        state.currentAmountText,
      );
      final currency = (targetMinor != null || currentMinor != null)
          ? state.currencyCode.trim().toUpperCase()
          : null;

      final milestones = <GoalMilestone>[
        for (var i = 0; i < state.milestoneTitles.length; i++)
          if (state.milestoneTitles[i].trim().isNotEmpty)
            GoalMilestone(
              id: uuid.v4(),
              goalId: id,
              title: state.milestoneTitles[i].trim(),
              order: i,
            ),
      ];

      final draft = Goal(
        id: id,
        name: state.name.trim(),
        description: state.description.trim(),
        category: state.category,
        customCategoryName: state.category == GoalCategory.custom
            ? state.customCategoryName.trim()
            : null,
        priority: state.priority,
        status: GoalStatus.active,
        targetAmountMinor: targetMinor,
        currentAmountMinor: currentMinor,
        currencyCode: currency,
        deadline: state.deadline!,
        createdAt: now,
        updatedAt: now,
        progressPercent: 0,
        notes: state.notes.trim(),
        milestones: milestones,
      );

      final created = await _ref
          .read(goalRepositoryProvider)
          .createGoal(GoalProgressCalculator.withRecalculatedProgress(draft));

      state = state.copyWith(isSubmitting: false);
      return created.id;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFacingErrorMessage(error),
      );
      return null;
    }
  }
}

final addGoalControllerProvider =
    StateNotifierProvider.autoDispose<AddGoalController, AddGoalFormState>((
      ref,
    ) {
      return AddGoalController(ref);
    });
