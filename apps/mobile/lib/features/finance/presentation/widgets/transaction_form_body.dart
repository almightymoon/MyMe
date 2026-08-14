import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/transaction_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';

class TransactionFormBody extends ConsumerStatefulWidget {
  const TransactionFormBody({
    super.key,
    required this.form,
    required this.controller,
    required this.onSave,
    this.saveLabel = 'Save transaction',
  });

  final TransactionFormState form;
  final TransactionFormController controller;
  final Future<void> Function() onSave;
  final String saveLabel;

  @override
  ConsumerState<TransactionFormBody> createState() =>
      _TransactionFormBodyState();
}

class _TransactionFormBodyState extends ConsumerState<TransactionFormBody> {
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final TextEditingController _merchantController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final form = widget.form;
    _amountController = TextEditingController(text: form.amountText);
    _currencyController = TextEditingController(text: form.currencyCode);
    _merchantController = TextEditingController(text: form.merchantOrSource);
    _noteController = TextEditingController(text: form.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final controller = widget.controller;
    final categoriesAsync = ref.watch(financeCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <FinanceCategory>[];
    final typeCategories = categories
        .where((c) => c.type == form.type && !c.isArchived)
        .toList(growable: false);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('transaction_form'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Type', style: AppTextStyles.labelMedium()),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<TransactionType>(
                  key: const Key('transaction_type_selector'),
                  segments: [
                    for (final type in TransactionType.values)
                      ButtonSegment(
                        value: type,
                        label: Text(type.label),
                        icon: Icon(
                          type == TransactionType.income
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                        ),
                      ),
                  ],
                  selected: {form.type},
                  onSelectionChanged: form.isSubmitting
                      ? null
                      : (values) => controller.setType(values.first),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        key: const Key('transaction_amount_field'),
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
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        key: const Key('transaction_currency_field'),
                        controller: _currencyController,
                        textCapitalization: TextCapitalization.characters,
                        enabled: !form.isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          errorText: form.fieldErrors['currencyCode'],
                        ),
                        onChanged: controller.setCurrencyCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  key: const Key('transaction_category_field'),
                  // ignore: deprecated_member_use
                  value: typeCategories.any((c) => c.id == form.categoryId)
                      ? form.categoryId
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    errorText: form.fieldErrors['categoryId'],
                  ),
                  items: [
                    for (final category in typeCategories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: form.isSubmitting
                      ? null
                      : (value) => controller.setCategoryId(value),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  key: const Key('transaction_datetime_field'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date & time',
                    style: AppTextStyles.labelMedium(),
                  ),
                  subtitle: Text(
                    form.fieldErrors['occurredAt'] ??
                        (form.occurredAt == null
                            ? 'Required'
                            : DateFormat.yMMMd().add_jm().format(
                                form.occurredAt!,
                              )),
                    style: AppTextStyles.bodyMedium(
                      color: form.fieldErrors['occurredAt'] != null
                          ? AppColors.health
                          : null,
                    ),
                  ),
                  trailing: const Icon(Icons.event_outlined),
                  onTap: form.isSubmitting
                      ? null
                      : () async {
                          final now = DateTime.now();
                          final initial = form.occurredAt ?? now;
                          final date = await showDatePicker(
                            context: context,
                            initialDate: initial.isAfter(now) ? now : initial,
                            firstDate: DateTime(now.year - 10),
                            lastDate: DateTime(now.year, now.month, now.day),
                          );
                          if (date == null || !context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(initial),
                          );
                          final hour = time?.hour ?? initial.hour;
                          final minute = time?.minute ?? initial.minute;
                          controller.setOccurredAt(
                            DateTime(
                              date.year,
                              date.month,
                              date.day,
                              hour,
                              minute,
                            ),
                          );
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentMethod>(
                  key: const Key('transaction_payment_method_field'),
                  // ignore: deprecated_member_use
                  value: form.paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment method',
                  ),
                  items: [
                    for (final method in PaymentMethod.values)
                      DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      ),
                  ],
                  onChanged: form.isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            controller.setPaymentMethod(value);
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('transaction_merchant_field'),
                  controller: _merchantController,
                  enabled: !form.isSubmitting,
                  decoration: InputDecoration(
                    labelText: form.type == TransactionType.income
                        ? 'Income source (optional)'
                        : 'Merchant (optional)',
                    errorText: form.fieldErrors['merchantOrSource'],
                  ),
                  onChanged: controller.setMerchantOrSource,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('transaction_note_field'),
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  enabled: !form.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    errorText: form.fieldErrors['note'],
                  ),
                  onChanged: controller.setNote,
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
            key: const Key('transaction_save_button'),
            label: form.isSubmitting ? 'Saving…' : widget.saveLabel,
            onPressed: form.isSubmitting
                ? null
                : () {
                    widget.onSave();
                  },
          ),
        ),
      ],
    );
  }
}
