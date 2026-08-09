import '../../domain/entities/finance_summary.dart';

class SpendCategory {
  const SpendCategory({
    required this.name,
    required this.pct,
    required this.amountLabel,
    required this.color,
  });

  final String name;
  final double pct;
  final String amountLabel;
  final ColorValue color;
}

/// Tiny RGB holder so seed stays free of Flutter imports.
class ColorValue {
  const ColorValue(this.value);
  final int value;
}

class MoneyParty {
  const MoneyParty({
    required this.name,
    required this.note,
    required this.amount,
    required this.amountLabel,
    required this.dueLabel,
    required this.status,
  });

  final String name;
  final String note;
  final int amount;
  final String amountLabel;
  final String dueLabel;

  /// overdue | due-soon | upcoming
  final String status;
}

/// Demo seed data from `/app/js/data.js` finance.
abstract final class FinanceSeed {
  static const FinanceSummary demoSummary = FinanceSummary(
    balanceLabel: 'PKR 245,000',
    spentTodayLabel: 'PKR 4,250',
    envelopeLabel: 'Coffee & lunch',
    incomeLabel: 'PKR 180,000',
    expensesLabel: 'PKR 89,000',
  );

  static const List<SpendCategory> categories = [
    SpendCategory(
      name: 'Food',
      pct: 30,
      amountLabel: 'PKR 26,700',
      color: ColorValue(0xFFE8501F),
    ),
    SpendCategory(
      name: 'Transport',
      pct: 20,
      amountLabel: 'PKR 17,800',
      color: ColorValue(0xFFFF7A2F),
    ),
    SpendCategory(
      name: 'Shopping',
      pct: 15,
      amountLabel: 'PKR 13,300',
      color: ColorValue(0xFFFFA51F),
    ),
    SpendCategory(
      name: 'Bills',
      pct: 15,
      amountLabel: 'PKR 13,300',
      color: ColorValue(0xFF3B82F6),
    ),
    SpendCategory(
      name: 'Others',
      pct: 20,
      amountLabel: 'PKR 17,900',
      color: ColorValue(0xFF9CA3AF),
    ),
  ];

  static const List<MoneyParty> lent = [
    MoneyParty(
      name: 'Sara Ahmed',
      note: 'Trip expenses',
      amount: 25000,
      amountLabel: 'PKR 25,000',
      dueLabel: 'Aug 20',
      status: 'due-soon',
    ),
    MoneyParty(
      name: 'Ali Raza',
      note: 'Laptop contribution',
      amount: 45000,
      amountLabel: 'PKR 45,000',
      dueLabel: 'Sep 05',
      status: 'upcoming',
    ),
    MoneyParty(
      name: 'Office lunch pool',
      note: 'Shared meals',
      amount: 3200,
      amountLabel: 'PKR 3,200',
      dueLabel: 'Aug 12',
      status: 'overdue',
    ),
  ];

  static const List<MoneyParty> loans = [
    MoneyParty(
      name: 'HBL Personal Loan',
      note: 'EMI · monthly',
      amount: 18500,
      amountLabel: 'PKR 18,500',
      dueLabel: 'Aug 15',
      status: 'due-soon',
    ),
    MoneyParty(
      name: 'Mom',
      note: 'Family support',
      amount: 50000,
      amountLabel: 'PKR 50,000',
      dueLabel: 'Oct 01',
      status: 'upcoming',
    ),
  ];

  static int get lentTotal =>
      lent.fold<int>(0, (sum, item) => sum + item.amount);

  static int get loanTotal =>
      loans.fold<int>(0, (sum, item) => sum + item.amount);

  static String formatPkr(int amount) {
    final digits = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buf.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return 'PKR $buf';
  }
}
