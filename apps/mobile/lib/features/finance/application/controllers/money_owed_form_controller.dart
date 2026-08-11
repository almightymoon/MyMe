import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../user/application/providers/user_providers.dart';
import '../../domain/entities/finance_money_position.dart';
import '../providers/finance_providers.dart';

class MoneyOwedFormState {
  const MoneyOwedFormState({
    this.direction = MoneyPositionDirection.iOwe,
    this.counterparty = '',
    this.amountText = '',
    this.note = '',
    this.dueDate,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.editingId,
  });

  final MoneyPositionDirection direction;
  final String counterparty;
  final String amountText;
  final String note;
  final LocalDate? dueDate;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? editingId;

  bool get isEditing => editingId != null;

  MoneyOwedFormState copyWith({
    MoneyPositionDirection? direction,
    String? counterparty,
    String? amountText,
    String? note,
    LocalDate? dueDate,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? editingId,
    bool clearError = false,
    bool clearDueDate = false,
  }) {
    return MoneyOwedFormState(
      direction: direction ?? this.direction,
      counterparty: counterparty ?? this.counterparty,
      amountText: amountText ?? this.amountText,
      note: note ?? this.note,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      editingId: editingId ?? this.editingId,
    );
  }
}

class MoneyOwedFormController extends StateNotifier<MoneyOwedFormState> {
  MoneyOwedFormController(this._ref, {FinanceMoneyPosition? existing})
    : super(
        existing == null
            ? const MoneyOwedFormState()
            : MoneyOwedFormState(
                direction: existing.direction,
                counterparty: existing.counterparty,
                amountText: MoneyFormat.majorStringFromMinor(
                  existing.originalAmountMinor,
                ),
                note: existing.note ?? '',
                dueDate: existing.dueDate,
                editingId: existing.id,
              ),
      );

  final Ref _ref;

  void _invalidateFinance() {
    _ref.invalidate(financeMoneyPositionsProvider);
  }

  static const int maxNameLength = 80;

  void setDirection(MoneyPositionDirection value) =>
      state = state.copyWith(direction: value, clearError: true);
  void setCounterparty(String value) =>
      state = state.copyWith(counterparty: value, clearError: true);
  void setAmountText(String value) =>
      state = state.copyWith(amountText: value, clearError: true);
  void setNote(String value) =>
      state = state.copyWith(note: value, clearError: true);
  void setDueDate(LocalDate? value) => state = state.copyWith(
    dueDate: value,
    clearDueDate: value == null,
    clearError: true,
  );

  void hydrate(FinanceMoneyPosition existing) {
    if (state.editingId == existing.id && state.amountText.isNotEmpty) {
      return;
    }
    state = MoneyOwedFormState(
      direction: existing.direction,
      counterparty: existing.counterparty,
      amountText: MoneyFormat.majorStringFromMinor(
        existing.originalAmountMinor,
      ),
      note: existing.note ?? '',
      dueDate: existing.dueDate,
      editingId: existing.id,
    );
  }

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (state.counterparty.trim().isEmpty) {
      errors['counterparty'] = 'Who this is with is required';
    } else if (state.counterparty.trim().length > maxNameLength) {
      errors['counterparty'] = 'Keep the name under $maxNameLength characters';
    }
    MoneyMinor? amount;
    try {
      amount = MoneyFormat.parseMajorToMinor(state.amountText);
    } on FormatException {
      errors['amount'] = 'Enter a valid amount';
    }
    if (amount == null) {
      errors['amount'] = 'Amount is required';
    } else if (!amount.isPositive) {
      errors['amount'] = 'Amount must be greater than zero';
    }
    return errors;
  }

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
      final repo = _ref.read(financeRepositoryProvider);
      final uuid = _ref.read(uuidProvider);
      final now = DateTime.now();
      final amount = MoneyFormat.parseMajorToMinor(state.amountText)!;
      final note = state.note.trim();
      if (state.isEditing) {
        final existing = await repo.getMoneyPosition(state.editingId!);
        if (existing == null) {
          throw AppException.notFound('Money owed entry not found.');
        }
        final updated = await repo.updateMoneyPosition(
          existing.copyWith(
            direction: state.direction,
            counterparty: state.counterparty.trim(),
            originalAmountMinor: amount,
            note: note,
            dueDate: state.dueDate,
            updatedAt: now,
            clearNote: note.isEmpty,
            clearDueDate: state.dueDate == null,
          ),
        );
        _invalidateFinance();
        state = state.copyWith(isSubmitting: false);
        return updated.id;
      }
      final created = await repo.createMoneyPosition(
        FinanceMoneyPosition(
          id: uuid.v4(),
          direction: state.direction,
          counterparty: state.counterparty.trim(),
          originalAmountMinor: amount,
          currencyCode: _ref.read(baseCurrencyProvider),
          note: note.isEmpty ? null : note,
          dueDate: state.dueDate,
          createdAt: now,
          updatedAt: now,
        ),
      );
      _invalidateFinance();
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

final addMoneyOwedControllerProvider =
    StateNotifierProvider.autoDispose<
      MoneyOwedFormController,
      MoneyOwedFormState
    >((ref) {
      return MoneyOwedFormController(ref);
    });

final editMoneyOwedControllerProvider = StateNotifierProvider.autoDispose
    .family<MoneyOwedFormController, MoneyOwedFormState, String>((
      ref,
      positionId,
    ) {
      return MoneyOwedFormController(ref);
    });
