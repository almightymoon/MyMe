import '../../domain/entities/finance_summary.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class FinanceSeed {
  static const FinanceSummary demoSummary = FinanceSummary(
    balanceLabel: 'PKR 245,000',
    spentTodayLabel: 'PKR 4,250',
    envelopeLabel: 'Coffee & lunch',
    incomeLabel: 'PKR 180,000',
    expensesLabel: 'PKR 89,000',
  );
}
