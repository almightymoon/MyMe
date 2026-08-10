import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../goals/application/providers/goal_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_enums.dart';
import '../providers/habit_providers.dart';

class HabitFormState {
  const HabitFormState({
    this.name = '',
    this.description = '',
    this.category = HabitCategory.health,
    this.customCategoryName = '',
    this.goalType = HabitGoalType.binary,
    this.targetValueText = '1',
    this.unitLabel = '',
    this.frequencyType = HabitFrequencyType.daily,
    this.selectedWeekdays = const [
      DateTime.monday,
      DateTime.wednesday,
      DateTime.friday,
    ],
    this.timesPerWeekText = '3',
    this.startDate,
    this.reminderEnabled = false,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.iconKey = 'check',
    this.colorKey = 'ember',
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.editingId,
  });

  final String name;
  final String description;
  final HabitCategory category;
  final String customCategoryName;
  final HabitGoalType goalType;
  final String targetValueText;
  final String unitLabel;
  final HabitFrequencyType frequencyType;
  final List<int> selectedWeekdays;
  final String timesPerWeekText;
  final LocalDate? startDate;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String iconKey;
  final String colorKey;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? editingId;

  bool get isEditing => editingId != null;

  HabitFormState copyWith({
    String? name,
    String? description,
    HabitCategory? category,
    String? customCategoryName,
    HabitGoalType? goalType,
    String? targetValueText,
    String? unitLabel,
    HabitFrequencyType? frequencyType,
    List<int>? selectedWeekdays,
    String? timesPerWeekText,
    LocalDate? startDate,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? iconKey,
    String? colorKey,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? editingId,
    bool clearError = false,
  }) {
    return HabitFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      customCategoryName: customCategoryName ?? this.customCategoryName,
      goalType: goalType ?? this.goalType,
      targetValueText: targetValueText ?? this.targetValueText,
      unitLabel: unitLabel ?? this.unitLabel,
      frequencyType: frequencyType ?? this.frequencyType,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      timesPerWeekText: timesPerWeekText ?? this.timesPerWeekText,
      startDate: startDate ?? this.startDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      editingId: editingId ?? this.editingId,
    );
  }
}

class HabitFormController extends StateNotifier<HabitFormState> {
  HabitFormController(this._ref, {Habit? existing})
    : super(
        existing == null ? const HabitFormState() : _stateFromHabit(existing),
      ) {
    if (existing == null && state.startDate == null) {
      state = state.copyWith(
        startDate: LocalDate.fromDateTime(_ref.read(appClockProvider).now()),
      );
    }
  }

  final Ref _ref;

  static HabitFormState _stateFromHabit(Habit habit) {
    return HabitFormState(
      name: habit.name,
      description: habit.description ?? '',
      category: habit.category,
      customCategoryName: habit.customCategoryName ?? '',
      goalType: habit.goalType,
      targetValueText: '${habit.targetValue}',
      unitLabel: habit.unitLabel ?? '',
      frequencyType: habit.frequencyType,
      selectedWeekdays: habit.selectedWeekdays,
      timesPerWeekText: '${habit.timesPerWeek ?? 3}',
      startDate: habit.startDate,
      reminderEnabled: habit.reminderHour != null,
      reminderHour: habit.reminderHour ?? 8,
      reminderMinute: habit.reminderMinute ?? 0,
      iconKey: habit.iconKey,
      colorKey: habit.colorKey,
      editingId: habit.id,
    );
  }

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setCategory(HabitCategory value) =>
      state = state.copyWith(category: value, clearError: true);
  void setCustomCategoryName(String value) =>
      state = state.copyWith(customCategoryName: value, clearError: true);
  void setGoalType(HabitGoalType value) {
    final target = value == HabitGoalType.binary ? '1' : state.targetValueText;
    state = state.copyWith(
      goalType: value,
      targetValueText: target,
      clearError: true,
    );
  }

  void setTargetValueText(String value) =>
      state = state.copyWith(targetValueText: value, clearError: true);
  void setUnitLabel(String value) => state = state.copyWith(unitLabel: value);
  void setFrequencyType(HabitFrequencyType value) =>
      state = state.copyWith(frequencyType: value, clearError: true);
  void setTimesPerWeekText(String value) =>
      state = state.copyWith(timesPerWeekText: value, clearError: true);
  void setStartDate(LocalDate value) =>
      state = state.copyWith(startDate: value, clearError: true);
  void setReminderEnabled(bool value) =>
      state = state.copyWith(reminderEnabled: value);
  void setReminderHour(int value) =>
      state = state.copyWith(reminderHour: value);
  void setReminderMinute(int value) =>
      state = state.copyWith(reminderMinute: value);
  void setIconKey(String value) => state = state.copyWith(iconKey: value);
  void setColorKey(String value) => state = state.copyWith(colorKey: value);

  void toggleWeekday(int weekday) {
    final next = [...state.selectedWeekdays];
    if (next.contains(weekday)) {
      next.remove(weekday);
    } else {
      next.add(weekday);
      next.sort();
    }
    state = state.copyWith(selectedWeekdays: next, clearError: true);
  }

  void hydrate(Habit habit) {
    if (state.editingId == habit.id && state.name.isNotEmpty) return;
    state = _stateFromHabit(habit);
  }

  Map<String, String> validate({LocalDate? asOf}) {
    final errors = <String, String>{};
    final today =
        asOf ?? LocalDate.fromDateTime(_ref.read(appClockProvider).now());

    if (state.name.trim().isEmpty) {
      errors['name'] = 'Habit name is required';
    }
    if (state.category == HabitCategory.custom &&
        state.customCategoryName.trim().isEmpty) {
      errors['customCategoryName'] = 'Enter a custom category name';
    }

    final target = int.tryParse(state.targetValueText.trim());
    if (target == null || target < 1) {
      errors['targetValue'] = 'Target must be at least 1';
    } else if (state.goalType == HabitGoalType.binary && target != 1) {
      errors['targetValue'] = 'Binary habits use a target of 1';
    }

    if (state.frequencyType == HabitFrequencyType.selectedWeekdays &&
        state.selectedWeekdays.isEmpty) {
      errors['selectedWeekdays'] = 'Pick at least one weekday';
    }

    if (state.frequencyType == HabitFrequencyType.timesPerWeek) {
      final times = int.tryParse(state.timesPerWeekText.trim());
      if (times == null || times < 1 || times > 7) {
        errors['timesPerWeek'] = 'Enter 1–7 times per week';
      }
    }

    if (state.startDate == null) {
      errors['startDate'] = 'Start date is required';
    } else if (state.startDate!.isAfter(today)) {
      errors['startDate'] = 'Start date cannot be in the future';
    }

    if (state.reminderEnabled) {
      if (state.reminderHour < 0 || state.reminderHour > 23) {
        errors['reminderHour'] = 'Hour must be 0–23';
      }
      if (state.reminderMinute < 0 || state.reminderMinute > 59) {
        errors['reminderMinute'] = 'Minute must be 0–59';
      }
    }

    return errors;
  }

  Habit _buildHabit({
    required String id,
    required DateTime now,
    Habit? existing,
  }) {
    final target = int.parse(state.targetValueText.trim());
    final unit = state.unitLabel.trim();
    final description = state.description.trim();
    final timesPerWeek = state.frequencyType == HabitFrequencyType.timesPerWeek
        ? int.parse(state.timesPerWeekText.trim())
        : null;

    return Habit(
      id: id,
      name: state.name.trim(),
      description: description.isEmpty ? null : description,
      category: state.category,
      customCategoryName: state.category == HabitCategory.custom
          ? state.customCategoryName.trim()
          : null,
      status: existing?.status ?? HabitStatus.active,
      goalType: state.goalType,
      targetValue: state.goalType == HabitGoalType.binary ? 1 : target,
      unitLabel: unit.isEmpty ? null : unit,
      frequencyType: state.frequencyType,
      selectedWeekdays:
          state.frequencyType == HabitFrequencyType.selectedWeekdays
          ? state.selectedWeekdays
          : const [],
      timesPerWeek: timesPerWeek,
      startDate: state.startDate!,
      reminderHour: state.reminderEnabled ? state.reminderHour : null,
      reminderMinute: state.reminderEnabled ? state.reminderMinute : null,
      iconKey: state.iconKey,
      colorKey: state.colorKey,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      archivedAt: existing?.archivedAt,
    );
  }

  /// Returns created habit id, or null on validation/submit failure.
  Future<String?> submitCreate() async {
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
      final now = _ref.read(appClockProvider).now();
      final id = uuid.v4();
      final habit = _buildHabit(id: id, now: now);
      final created = await _ref
          .read(habitRepositoryProvider)
          .createHabit(habit);
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

  /// Returns updated habit id, or null on validation/submit failure.
  Future<String?> submitUpdate() async {
    if (state.isSubmitting || state.editingId == null) return null;

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
      final repo = _ref.read(habitRepositoryProvider);
      final existing = await repo.getHabit(state.editingId!);
      if (existing == null) {
        throw StateError('Habit not found');
      }
      final now = _ref.read(appClockProvider).now();
      final updated = await repo.updateHabit(
        _buildHabit(id: existing.id, now: now, existing: existing),
      );
      state = state.copyWith(isSubmitting: false);
      return updated.id;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFacingErrorMessage(error),
      );
      return null;
    }
  }
}

final addHabitFormControllerProvider =
    StateNotifierProvider.autoDispose<HabitFormController, HabitFormState>((
      ref,
    ) {
      return HabitFormController(ref);
    });

final editHabitFormControllerProvider = StateNotifierProvider.autoDispose
    .family<HabitFormController, HabitFormState, String>((ref, habitId) {
      return HabitFormController(ref);
    });
