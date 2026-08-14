import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/add_goal_controller.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/services/money_format.dart';

class AddGoalScreen extends ConsumerWidget {
  const AddGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addGoalControllerProvider);
    final controller = ref.read(addGoalControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: AppStrings.addGoal,
              subtitle: 'Create a locally saved goal',
              leading: IconButton(
                key: const Key('add_goal_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.goals),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('add_goal_form'),
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
                      key: const Key('goal_name_field'),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Goal name',
                        errorText: form.fieldErrors['name'],
                      ),
                      onChanged: controller.setName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const Key('goal_description_field'),
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: controller.setDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<GoalCategory>(
                      key: const Key('goal_category_field'),
                      // ignore: deprecated_member_use
                      value: form.category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        for (final category in GoalCategory.values)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.setCategory(value);
                      },
                    ),
                    if (form.category == GoalCategory.custom) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        key: const Key('goal_custom_category_field'),
                        decoration: InputDecoration(
                          labelText: 'Custom category',
                          errorText: form.fieldErrors['customCategoryName'],
                        ),
                        onChanged: controller.setCustomCategoryName,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<GoalPriority>(
                      key: const Key('goal_priority_field'),
                      // ignore: deprecated_member_use
                      value: form.priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: [
                        for (final priority in GoalPriority.values)
                          DropdownMenuItem(
                            value: priority,
                            child: Text(priority.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.setPriority(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            key: const Key('goal_target_amount_field'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Target amount (optional)',
                              errorText: form.fieldErrors['targetAmount'],
                            ),
                            onChanged: controller.setTargetAmountText,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            key: const Key('goal_currency_field'),
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Currency',
                              hintText: MoneyFormat.defaultCurrencyCode,
                              errorText: form.fieldErrors['currencyCode'],
                            ),
                            onChanged: controller.setCurrencyCode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const Key('goal_current_amount_field'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Current amount (optional)',
                        errorText: form.fieldErrors['currentAmount'],
                      ),
                      onChanged: controller.setCurrentAmountText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ListTile(
                      key: const Key('goal_deadline_field'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Deadline',
                        style: AppTextStyles.labelMedium(),
                      ),
                      subtitle: Text(
                        form.fieldErrors['deadline'] ??
                            (form.deadline == null
                                ? 'Required'
                                : DateFormat.yMMMd().format(form.deadline!)),
                        style: AppTextStyles.bodyMedium(
                          color: form.fieldErrors['deadline'] != null
                              ? AppColors.health
                              : null,
                        ),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              form.deadline ??
                              now.add(const Duration(days: 30)),
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: DateTime(now.year + 30),
                        );
                        if (picked != null) controller.setDeadline(picked);
                      },
                    ),
                    if (form.fieldErrors['deadline'] != null)
                      Text(
                        form.fieldErrors['deadline']!,
                        style: AppTextStyles.bodySmall(color: AppColors.health),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const Key('goal_notes_field'),
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      onChanged: controller.setNotes,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Initial milestones',
                      style: AppTextStyles.titleSmall(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (var i = 0; i < form.milestoneTitles.length; i++) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: Key('goal_milestone_field_$i'),
                              decoration: InputDecoration(
                                labelText: 'Milestone ${i + 1}',
                              ),
                              onChanged: (value) =>
                                  controller.setMilestoneTitle(i, value),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove milestone',
                            onPressed: () => controller.removeMilestoneField(i),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    TextButton.icon(
                      key: const Key('goal_add_milestone_field'),
                      onPressed: controller.addMilestoneField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add milestone'),
                    ),
                    if (form.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        form.errorMessage!,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.health,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: MemyPrimaryButton(
                key: const Key('goal_save_button'),
                label: form.isSubmitting ? 'Saving…' : 'Save goal',
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        final id = await controller.submit();
                        if (!context.mounted || id == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Goal saved on this device'),
                          ),
                        );
                        context.go(RoutePaths.goalDetailPath(id));
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
