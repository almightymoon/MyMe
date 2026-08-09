import '../../../../core/domain/value_objects/money_minor.dart';

/// Expense share for one category inside a selected period.
///
/// [percentageBasisPoints] is `floor(amount × 10000 ÷ periodExpenseTotal)`
/// (10000 = 100.00%). When the period expense total is zero, basis points
/// are zero.
class FinanceCategoryBreakdown {
  const FinanceCategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amountMinor,
    required this.percentageBasisPoints,
  });

  final String categoryId;
  final String categoryName;
  final MoneyMinor amountMinor;
  final int percentageBasisPoints;

  /// Whole-percent display helper (truncated toward zero).
  int get percentageRounded => percentageBasisPoints ~/ 100;
}
