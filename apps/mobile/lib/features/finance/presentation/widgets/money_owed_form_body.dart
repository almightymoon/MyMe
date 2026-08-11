import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/money_owed_form_controller.dart';
import '../../domain/entities/finance_money_position.dart';

class MoneyOwedFormBody extends StatefulWidget {
  const MoneyOwedFormBody({
    super.key,
    required this.form,
    required this.controller,
    required this.onSave,
    this.saveLabel = 'Save',
  });

  final MoneyOwedFormState form;
  final MoneyOwedFormController controller;
  final Future<void> Function() onSave;
  final String saveLabel;

  @override
  State<MoneyOwedFormBody> createState() => _MoneyOwedFormBodyState();
}

class _MoneyOwedFormBodyState extends State<MoneyOwedFormBody> {
  late final TextEditingController _counterpartyController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _counterpartyController = TextEditingController(
      text: widget.form.counterparty,
    );
    _amountController = TextEditingController(text: widget.form.amountText);
    _noteController = TextEditingController(text: widget.form.note);
  }

  @override
  void dispose() {
    _counterpartyController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final controller = widget.controller;
    final dueLabel = form.dueDate == null
        ? 'Optional'
        : DateFormat.yMMMd().format(form.dueDate!.toDateTimeLocal());

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('money_owed_form'),
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
                SegmentedButton<MoneyPositionDirection>(
                  key: const Key('money_owed_direction'),
                  segments: const [
                    ButtonSegment(
                      value: MoneyPositionDirection.iOwe,
                      label: Text('I owe'),
                    ),
                    ButtonSegment(
                      value: MoneyPositionDirection.owedToMe,
                      label: Text('Owed to me'),
                    ),
                  ],
                  selected: {form.direction},
                  onSelectionChanged: form.isSubmitting
                      ? null
                      : (value) => controller.setDirection(value.first),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('money_owed_counterparty_field'),
                  controller: _counterpartyController,
                  enabled: !form.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Person or label',
                    errorText: form.fieldErrors['counterparty'],
                  ),
                  onChanged: controller.setCounterparty,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const Key('money_owed_amount_field'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !form.isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Original amount',
                    errorText: form.fieldErrors['amount'],
                  ),
                  onChanged: controller.setAmountText,
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    key: const Key('money_owed_due_field'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Due date'),
                    subtitle: Text(dueLabel),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (form.dueDate != null)
                          IconButton(
                            key: const Key('money_owed_clear_due'),
                            tooltip: 'Clear due date',
                            onPressed: form.isSubmitting
                                ? null
                                : () => controller.setDueDate(null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        const Icon(Icons.event_outlined),
                      ],
                    ),
                    onTap: form.isSubmitting
                        ? null
                        : () async {
                            final initial =
                                form.dueDate?.toDateTimeLocal() ??
                                DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(DateTime.now().year - 5),
                              lastDate: DateTime(DateTime.now().year + 5),
                            );
                            if (picked == null) return;
                            controller.setDueDate(
                              LocalDate.fromDateTime(picked),
                            );
                          },
                  ),
                ),
                TextField(
                  key: const Key('money_owed_note_field'),
                  controller: _noteController,
                  enabled: !form.isSubmitting,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                  onChanged: controller.setNote,
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
            key: const Key('money_owed_save_button'),
            label: form.isSubmitting ? 'Saving…' : widget.saveLabel,
            onPressed: form.isSubmitting
                ? null
                : () {
                    controller.setCounterparty(_counterpartyController.text);
                    controller.setAmountText(_amountController.text);
                    controller.setNote(_noteController.text);
                    widget.onSave();
                  },
          ),
        ),
      ],
    );
  }
}
