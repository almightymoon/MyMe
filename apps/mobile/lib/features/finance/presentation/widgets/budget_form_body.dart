import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/domain/value_objects/year_month.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/budget_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_enums.dart';

class BudgetFormBody extends ConsumerStatefulWidget {
  const BudgetFormBody({
    super.key,
    required this.form,
    required this.controller,
    required this.onSave,
    this.saveLabel = 'Save budget',
  });

  final BudgetFormState form;
  final BudgetFormController controller;
  final Future<void> Function() onSave;
  final String saveLabel;

  @override
  ConsumerState<BudgetFormBody> createState() => _BudgetFormBodyState();
}

class _BudgetFormBodyState extends ConsumerState<BudgetFormBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.form.name);
    _amountController = TextEditingController(text: widget.form.amountText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final controller = widget.controller;
    final categories =
        (ref.watch(financeCategoriesProvider).valueOrNull ?? const [])
            .where((c) => c.type == TransactionType.expense && !c.isArchived)
            .toList(growable: false);
    final month = form.month ?? YearMonth.fromDateTime(DateTime.now());
    final monthLabel = DateFormat.yMMMM().format(month.startLocal);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('budget_form'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (form.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(form.errorMessage!),
                  ),
                TextField(
                  key: const Key('budget_name_field'),
                  controller: _nameController,
                  enabled: !form.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: form.fieldErrors['name'],
                  ),
                  onChanged: controller.setName,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('budget_amount_field'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !form.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    errorText: form.fieldErrors['amount'],
                  ),
                  onChanged: controller.setAmountText,
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    key: const Key('budget_month_field'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Month'),
                    subtitle: Text(form.fieldErrors['month'] ?? monthLabel),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: form.isSubmitting
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: month.startLocal,
                              firstDate: DateTime(DateTime.now().year - 5),
                              lastDate: DateTime(DateTime.now().year + 2),
                              helpText: 'Choose any day in the month',
                            );
                            if (picked == null) return;
                            controller.setMonth(YearMonth.fromDateTime(picked));
                          },
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    key: const Key('budget_overall_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Overall monthly budget'),
                    value: form.isOverall,
                    onChanged: form.isSubmitting ? null : controller.setOverall,
                  ),
                ),
                if (!form.isOverall)
                  DropdownButtonFormField<String>(
                    key: const Key('budget_category_field'),
                    // ignore: deprecated_member_use
                    value: categories.any((c) => c.id == form.categoryId)
                        ? form.categoryId
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      errorText: form.fieldErrors['categoryId'],
                    ),
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: form.isSubmitting
                        ? null
                        : controller.setCategoryId,
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Warn at ${(form.warningThresholdBasisPoints / 100).round()}% spent',
                ),
                Slider(
                  key: const Key('budget_warning_slider'),
                  value: form.warningThresholdBasisPoints.toDouble(),
                  min: 5000,
                  max: 10000,
                  divisions: 10,
                  label: '${(form.warningThresholdBasisPoints / 100).round()}%',
                  onChanged: form.isSubmitting
                      ? null
                      : (value) => controller.setWarningThresholdBasisPoints(
                          value.round(),
                        ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: MemyPrimaryButton(
            key: const Key('budget_save_button'),
            label: form.isSubmitting ? 'Saving…' : widget.saveLabel,
            onPressed: form.isSubmitting
                ? null
                : () {
                    controller.setName(_nameController.text);
                    controller.setAmountText(_amountController.text);
                    widget.onSave();
                  },
          ),
        ),
      ],
    );
  }
}
