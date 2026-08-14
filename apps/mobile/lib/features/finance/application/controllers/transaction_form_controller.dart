import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../user/application/providers/user_providers.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_transaction.dart';
import '../providers/finance_providers.dart';

class TransactionFormState {
  const TransactionFormState({
    this.type = TransactionType.expense,
    this.amountText = '',
    this.currencyCode = MoneyFormat.defaultCurrencyCode,
    this.categoryId,
    this.occurredAt,
    this.paymentMethod = PaymentMethod.cash,
    this.merchantOrSource = '',
    this.note = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.editingId,
  });

  final TransactionType type;
  final String amountText;
  final String currencyCode;
  final String? categoryId;
  final DateTime? occurredAt;
  final PaymentMethod paymentMethod;
  final String merchantOrSource;
  final String note;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? editingId;

  bool get isEditing => editingId != null;

  TransactionFormState copyWith({
    TransactionType? type,
    String? amountText,
    String? currencyCode,
    String? categoryId,
    DateTime? occurredAt,
    PaymentMethod? paymentMethod,
    String? merchantOrSource,
    String? note,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? editingId,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      amountText: amountText ?? this.amountText,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      occurredAt: occurredAt ?? this.occurredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantOrSource: merchantOrSource ?? this.merchantOrSource,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      editingId: editingId ?? this.editingId,
    );
  }
}

class TransactionFormController extends StateNotifier<TransactionFormState> {
  TransactionFormController(this._ref, {FinanceTransaction? existing})
    : super(
        existing == null
            ? TransactionFormState(
                occurredAt: DateTime.now(),
                currencyCode: _ref.read(baseCurrencyProvider),
              )
            : TransactionFormState(
                type: existing.type,
                amountText: MoneyFormat.majorStringFromMinor(
                  existing.amountMinor,
                ),
                currencyCode: existing.currencyCode,
                categoryId: existing.categoryId,
                occurredAt: existing.occurredAt,
                paymentMethod: existing.paymentMethod,
                merchantOrSource: existing.merchantOrSource ?? '',
                note: existing.note ?? '',
                editingId: existing.id,
              ),
      );

  final Ref _ref;

  void _invalidateFinance() {
    _ref
      ..invalidate(financeTransactionsProvider)
      ..invalidate(financeCategoriesProvider)
      ..invalidate(financeBudgetsProvider);
  }

  static const int maxMerchantLength = 80;
  static const int maxNoteLength = 280;

  void setType(TransactionType value) {
    state = state.copyWith(type: value, clearCategory: true, clearError: true);
  }

  void setAmountText(String value) =>
      state = state.copyWith(amountText: value, clearError: true);
  void setCurrencyCode(String value) =>
      state = state.copyWith(currencyCode: value.toUpperCase());
  void setCategoryId(String? value) =>
      state = state.copyWith(categoryId: value, clearError: true);
  void setOccurredAt(DateTime value) =>
      state = state.copyWith(occurredAt: value, clearError: true);
  void setPaymentMethod(PaymentMethod value) =>
      state = state.copyWith(paymentMethod: value);
  void setMerchantOrSource(String value) =>
      state = state.copyWith(merchantOrSource: value);
  void setNote(String value) => state = state.copyWith(note: value);

  /// Populate form from an existing transaction (edit flow).
  void hydrate(FinanceTransaction existing) {
    if (state.editingId == existing.id && state.amountText.isNotEmpty) {
      return;
    }
    state = TransactionFormState(
      type: existing.type,
      amountText: MoneyFormat.majorStringFromMinor(existing.amountMinor),
      currencyCode: existing.currencyCode,
      categoryId: existing.categoryId,
      occurredAt: existing.occurredAt,
      paymentMethod: existing.paymentMethod,
      merchantOrSource: existing.merchantOrSource ?? '',
      note: existing.note ?? '',
      editingId: existing.id,
    );
  }

  Map<String, String> validate({
    DateTime? asOf,
    Set<String>? validCategoryIds,
  }) {
    final errors = <String, String>{};
    final now = asOf ?? DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

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

    final currency = state.currencyCode.trim().toUpperCase();
    if (currency.isEmpty) {
      errors['currencyCode'] = 'Currency is required';
    } else if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      errors['currencyCode'] = 'Use a 3-letter currency code';
    }

    final categoryId = state.categoryId;
    if (categoryId == null || categoryId.isEmpty) {
      errors['categoryId'] = 'Category is required';
    } else if (validCategoryIds != null &&
        !validCategoryIds.contains(categoryId)) {
      errors['categoryId'] = 'Choose a category for this type';
    }

    if (state.occurredAt == null) {
      errors['occurredAt'] = 'Date is required';
    } else if (state.occurredAt!.isAfter(todayEnd)) {
      errors['occurredAt'] = 'Future dates are not allowed';
    }

    if (state.merchantOrSource.trim().length > maxMerchantLength) {
      errors['merchantOrSource'] =
          'Keep merchant / source under $maxMerchantLength characters';
    }
    if (state.note.trim().length > maxNoteLength) {
      errors['note'] = 'Keep notes under $maxNoteLength characters';
    }

    return errors;
  }

  /// Returns saved transaction id, or null on validation/submit failure.
  Future<String?> submit({Set<String>? validCategoryIds}) async {
    if (state.isSubmitting) return null;

    final errors = validate(validCategoryIds: validCategoryIds);
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
      final currency = state.currencyCode.trim().toUpperCase();
      final merchant = state.merchantOrSource.trim();
      final note = state.note.trim();

      if (state.isEditing) {
        final existing = await repo.getTransaction(state.editingId!);
        if (existing == null) {
          throw StateError('Transaction not found');
        }
        final updated = await repo.updateTransaction(
          existing.copyWith(
            type: state.type,
            amountMinor: amount,
            currencyCode: currency,
            categoryId: state.categoryId!,
            occurredAt: state.occurredAt!,
            paymentMethod: state.paymentMethod,
            merchantOrSource: merchant.isEmpty ? null : merchant,
            note: note.isEmpty ? null : note,
            clearMerchantOrSource: merchant.isEmpty,
            clearNote: note.isEmpty,
            updatedAt: now,
          ),
        );
        _invalidateFinance();
        state = state.copyWith(isSubmitting: false);
        return updated.id;
      }

      final id = uuid.v4();
      final created = await repo.createTransaction(
        FinanceTransaction(
          id: id,
          type: state.type,
          amountMinor: amount,
          currencyCode: currency,
          categoryId: state.categoryId!,
          occurredAt: state.occurredAt!,
          paymentMethod: state.paymentMethod,
          merchantOrSource: merchant.isEmpty ? null : merchant,
          note: note.isEmpty ? null : note,
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

final addTransactionControllerProvider =
    StateNotifierProvider.autoDispose<
      TransactionFormController,
      TransactionFormState
    >((ref) {
      return TransactionFormController(ref);
    });

final editTransactionControllerProvider = StateNotifierProvider.autoDispose
    .family<TransactionFormController, TransactionFormState, String>((
      ref,
      transactionId,
    ) {
      return TransactionFormController(ref);
    });
