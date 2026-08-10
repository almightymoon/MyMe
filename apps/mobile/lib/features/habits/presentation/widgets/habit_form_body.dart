import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../application/controllers/habit_form_controller.dart';
import '../../domain/entities/habit_enums.dart';

class HabitFormBody extends StatefulWidget {
  const HabitFormBody({
    super.key,
    required this.form,
    required this.controller,
  });

  final HabitFormState form;
  final HabitFormController controller;

  @override
  State<HabitFormBody> createState() => _HabitFormBodyState();
}

class _HabitFormBodyState extends State<HabitFormBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _unitLabelController;
  late final TextEditingController _timesPerWeekController;
  late final TextEditingController _reminderHourController;
  late final TextEditingController _reminderMinuteController;

  static const _iconOptions = <String, IconData>{
    'check': Icons.check_circle_outline,
    'walk': Icons.directions_walk_rounded,
    'book': Icons.menu_book_rounded,
    'water': Icons.water_drop_outlined,
    'fitness': Icons.fitness_center_rounded,
    'mind': Icons.self_improvement_rounded,
  };

  static const _colorOptions = <String, Color>{
    'ember': AppColors.ember,
    'health': AppColors.health,
    'learning': AppColors.learning,
    'habits': AppColors.habits,
    'finance': AppColors.finance,
  };

  static const _weekdayLabels = {
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    final form = widget.form;
    _nameController = TextEditingController(text: form.name);
    _descriptionController = TextEditingController(text: form.description);
    _customCategoryController = TextEditingController(
      text: form.customCategoryName,
    );
    _targetValueController = TextEditingController(text: form.targetValueText);
    _unitLabelController = TextEditingController(text: form.unitLabel);
    _timesPerWeekController = TextEditingController(
      text: form.timesPerWeekText,
    );
    _reminderHourController = TextEditingController(
      text: '${form.reminderHour}',
    );
    _reminderMinuteController = TextEditingController(
      text: '${form.reminderMinute}',
    );
  }

  @override
  void didUpdateWidget(covariant HabitFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final form = widget.form;
    if (oldWidget.form.name != form.name && _nameController.text != form.name) {
      _nameController.text = form.name;
    }
    if (oldWidget.form.description != form.description &&
        _descriptionController.text != form.description) {
      _descriptionController.text = form.description;
    }
    if (oldWidget.form.customCategoryName != form.customCategoryName) {
      _customCategoryController.text = form.customCategoryName;
    }
    if (oldWidget.form.targetValueText != form.targetValueText) {
      _targetValueController.text = form.targetValueText;
    }
    if (oldWidget.form.unitLabel != form.unitLabel) {
      _unitLabelController.text = form.unitLabel;
    }
    if (oldWidget.form.timesPerWeekText != form.timesPerWeekText) {
      _timesPerWeekController.text = form.timesPerWeekText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _targetValueController.dispose();
    _unitLabelController.dispose();
    _timesPerWeekController.dispose();
    _reminderHourController.dispose();
    _reminderMinuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final controller = widget.controller;

    return SingleChildScrollView(
      key: const Key('habit_form_scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('habit_name_field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Habit name',
              errorText: form.fieldErrors['name'],
            ),
            onChanged: controller.setName,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('habit_description_field'),
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
            onChanged: controller.setDescription,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<HabitCategory>(
            key: const Key('habit_category_field'),
            // ignore: deprecated_member_use
            value: form.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final category in HabitCategory.values)
                DropdownMenuItem(value: category, child: Text(category.label)),
            ],
            onChanged: (value) {
              if (value != null) controller.setCategory(value);
            },
          ),
          if (form.category == HabitCategory.custom) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('habit_custom_category_field'),
              controller: _customCategoryController,
              decoration: InputDecoration(
                labelText: 'Custom category',
                errorText: form.fieldErrors['customCategoryName'],
              ),
              onChanged: controller.setCustomCategoryName,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<HabitGoalType>(
            key: const Key('habit_goal_type_field'),
            // ignore: deprecated_member_use
            value: form.goalType,
            decoration: const InputDecoration(labelText: 'Goal type'),
            items: [
              for (final type in HabitGoalType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) {
              if (value != null) controller.setGoalType(value);
            },
          ),
          if (form.goalType != HabitGoalType.binary) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('habit_target_value_field'),
              controller: _targetValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: form.goalType == HabitGoalType.duration
                    ? 'Target (minutes)'
                    : 'Target count',
                errorText: form.fieldErrors['targetValue'],
              ),
              onChanged: controller.setTargetValueText,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('habit_unit_label_field'),
              controller: _unitLabelController,
              decoration: const InputDecoration(
                labelText: 'Unit label (optional)',
                hintText: 'glasses, pages, …',
              ),
              onChanged: controller.setUnitLabel,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<HabitFrequencyType>(
            key: const Key('habit_frequency_field'),
            // ignore: deprecated_member_use
            value: form.frequencyType,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: [
              for (final type in HabitFrequencyType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) {
              if (value != null) controller.setFrequencyType(value);
            },
          ),
          if (form.frequencyType == HabitFrequencyType.selectedWeekdays) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Weekdays', style: AppTextStyles.labelMedium()),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final weekday in _weekdayLabels.keys)
                  FilterChip(
                    key: Key('habit_weekday_$weekday'),
                    label: Text(_weekdayLabels[weekday]!),
                    selected: form.selectedWeekdays.contains(weekday),
                    onSelected: (_) => controller.toggleWeekday(weekday),
                  ),
              ],
            ),
            if (form.fieldErrors['selectedWeekdays'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  form.fieldErrors['selectedWeekdays']!,
                  style: AppTextStyles.bodySmall(color: AppColors.health),
                ),
              ),
          ],
          if (form.frequencyType == HabitFrequencyType.timesPerWeek) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('habit_times_per_week_field'),
              controller: _timesPerWeekController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Times per week',
                errorText: form.fieldErrors['timesPerWeek'],
              ),
              onChanged: controller.setTimesPerWeekText,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ListTile(
            key: const Key('habit_start_date_field'),
            contentPadding: EdgeInsets.zero,
            title: Text('Start date', style: AppTextStyles.labelMedium()),
            subtitle: Text(
              form.fieldErrors['startDate'] ??
                  (form.startDate == null
                      ? 'Required'
                      : DateFormat.yMMMd().format(
                          form.startDate!.toDateTimeLocal(),
                        )),
              style: AppTextStyles.bodyMedium(
                color: form.fieldErrors['startDate'] != null
                    ? AppColors.health
                    : null,
              ),
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final now = DateTime.now();
              final initial = form.startDate?.toDateTimeLocal() ?? now;
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(now.year - 5),
                lastDate: now,
              );
              if (picked != null) {
                controller.setStartDate(LocalDate.fromDateTime(picked));
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            key: const Key('habit_reminder_toggle'),
            contentPadding: EdgeInsets.zero,
            title: Text('Daily reminder', style: AppTextStyles.labelMedium()),
            value: form.reminderEnabled,
            onChanged: controller.setReminderEnabled,
          ),
          if (form.reminderEnabled) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('habit_reminder_hour_field'),
                    controller: _reminderHourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Hour',
                      errorText: form.fieldErrors['reminderHour'],
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) controller.setReminderHour(parsed);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    key: const Key('habit_reminder_minute_field'),
                    controller: _reminderMinuteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Minute',
                      errorText: form.fieldErrors['reminderMinute'],
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) controller.setReminderMinute(parsed);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Icon', style: AppTextStyles.labelMedium()),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _iconOptions.entries)
                ChoiceChip(
                  key: Key('habit_icon_${entry.key}'),
                  label: Icon(entry.value),
                  selected: form.iconKey == entry.key,
                  onSelected: (_) => controller.setIconKey(entry.key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Accent color', style: AppTextStyles.labelMedium()),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _colorOptions.entries)
                ChoiceChip(
                  key: Key('habit_color_${entry.key}'),
                  label: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  selected: form.colorKey == entry.key,
                  onSelected: (_) => controller.setColorKey(entry.key),
                ),
            ],
          ),
          if (form.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              form.errorMessage!,
              style: AppTextStyles.bodyMedium(color: AppColors.health),
            ),
          ],
        ],
      ),
    );
  }
}
