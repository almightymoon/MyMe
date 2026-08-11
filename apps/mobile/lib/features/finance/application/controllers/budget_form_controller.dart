import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/domain/value_objects/year_month.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/seed/finance_seed.dart';
import '../../domain/entities/finance_budget.dart';
import '../providers/finance_providers.dart';

class BudgetFormState {
  const BudgetFormState({
    this.name = '',
    this.amountText = '',
    this.month,
    this.categoryId,
    this.isOverall = true,
    this.warningThresholdBasisPoints = 8000,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.editingId,
  });

  final String name;
  final String amountText;
  final YearMonth? month;
  final String? categoryId;
  final bool isOverall;
  final int warningThresholdBasisPoints;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? editingId;

  bool get isEditing => editingId != null;

  BudgetFormState copyWith({
    String? name,
    String? amountText,
    YearMonth? month,
    String? categoryId,
    bool? isOverall,
    int? warningThresholdBasisPoints,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? editingId,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return BudgetFormState(
      name: name ?? this.name,
      amountText: amountText ?? this.amountText,
      month: month ?? this.month,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      isOverall: isOverall ?? this.isOverall,
      warningThresholdBasisPoints:
          warningThresholdBasisPoints ?? this.warningThresholdBasisPoints,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      editingId: editingId ?? this.editingId,
    );
  }
}

class BudgetFormController extends StateNotifier<BudgetFormState> {
  BudgetFormController(this._ref, {FinanceBudget? existing})
    : super(
        existing == null
            ? BudgetFormState(
                month: YearMonth.fromDateTime(DateTime.now()),
                name: 'Monthly budget',
              )
            : BudgetFormState(
                name: existing.name,
                amountText: MoneyFormat.majorStringFromMinor(
                  existing.amountMinor,
                ),
                month: existing.month,
                categoryId: existing.categoryId,
                isOverall: existing.isOverall,
                warningThresholdBasisPoints:
                    existing.warningThresholdBasisPoints,
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

  static const int maxNameLength = 80;

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);
  void setAmountText(String value) =>
      state = state.copyWith(amountText: value, clearError: true);
  void setMonth(YearMonth value) =>
      state = state.copyWith(month: value, clearError: true);
  void setOverall(bool value) => state = state.copyWith(
    isOverall: value,
    clearCategory: value,
    clearError: true,
  );
  void setCategoryId(String? value) =>
      state = state.copyWith(categoryId: value, clearError: true);
  void setWarningThresholdBasisPoints(int value) =>
      state = state.copyWith(warningThresholdBasisPoints: value);

  void hydrate(FinanceBudget existing) {
    if (state.editingId == existing.id && state.amountText.isNotEmpty) {
      return;
    }
    state = BudgetFormState(
      name: existing.name,
      amountText: MoneyFormat.majorStringFromMinor(existing.amountMinor),
      month: existing.month,
      categoryId: existing.categoryId,
      isOverall: existing.isOverall,
      warningThresholdBasisPoints: existing.warningThresholdBasisPoints,
      editingId: existing.id,
    );
  }

  Map<String, String> validate() {
    final errors = <String, String>{};
    if (state.name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (state.name.trim().length > maxNameLength) {
      errors['name'] = 'Keep the name under $maxNameLength characters';
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
    if (state.month == null) {
      errors['month'] = 'Month is required';
    }
    if (!state.isOverall &&
        (state.categoryId == null || state.categoryId!.isEmpty)) {
      errors['categoryId'] = 'Choose a category';
    }
    final threshold = state.warningThresholdBasisPoints;
    if (threshold < 0 || threshold > 10000) {
      errors['warning'] = 'Warning threshold must be between 0% and 100%';
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
      final budget = FinanceBudget(
        id: state.editingId ?? uuid.v4(),
        name: state.name.trim(),
        categoryId: state.isOverall ? null : state.categoryId,
        month: state.month!,
        amountMinor: amount,
        currencyCode: FinanceSeed.baseCurrencyCode,
        warningThresholdBasisPoints: state.warningThresholdBasisPoints,
        createdAt: now,
        updatedAt: now,
      );
      if (state.isEditing) {
        final existing = await repo.getBudget(state.editingId!);
        if (existing == null) {
          throw AppException.notFound('Budget not found.');
        }
        final updated = await repo.updateBudget(
          existing.copyWith(
            name: budget.name,
            categoryId: budget.categoryId,
            month: budget.month,
            amountMinor: budget.amountMinor,
            warningThresholdBasisPoints: budget.warningThresholdBasisPoints,
            updatedAt: now,
            clearCategoryId: budget.isOverall,
          ),
        );
        _invalidateFinance();
        state = state.copyWith(isSubmitting: false);
        return updated.id;
      }
      final created = await repo.createBudget(budget);
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

final addBudgetControllerProvider =
    StateNotifierProvider.autoDispose<BudgetFormController, BudgetFormState>((
      ref,
    ) {
      return BudgetFormController(ref);
    });

final editBudgetControllerProvider = StateNotifierProvider.autoDispose
    .family<BudgetFormController, BudgetFormState, String>((ref, budgetId) {
      return BudgetFormController(ref);
    });
