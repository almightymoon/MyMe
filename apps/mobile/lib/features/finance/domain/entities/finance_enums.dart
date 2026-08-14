/// Income vs expense classification for finance transactions and categories.
enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
  };

  static TransactionType? tryParse(String? raw) {
    if (raw == null) return null;
    switch (raw.trim().toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// How a transaction was paid or received.
enum PaymentMethod {
  cash,
  bankTransfer,
  debitCard,
  creditCard,
  mobileWallet,
  other;

  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.bankTransfer => 'Bank transfer',
    PaymentMethod.debitCard => 'Debit card',
    PaymentMethod.creditCard => 'Credit card',
    PaymentMethod.mobileWallet => 'Mobile wallet',
    PaymentMethod.other => 'Other',
  };

  static PaymentMethod? tryParse(String? raw) {
    if (raw == null) return null;
    switch (raw.trim()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'bankTransfer':
        return PaymentMethod.bankTransfer;
      case 'debitCard':
        return PaymentMethod.debitCard;
      case 'creditCard':
        return PaymentMethod.creditCard;
      case 'mobileWallet':
        return PaymentMethod.mobileWallet;
      case 'other':
        return PaymentMethod.other;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Overview / history period filter.
enum FinancePeriod {
  thisMonth,
  lastMonth,
  thisYear,
  allTime;

  String get label => switch (this) {
    FinancePeriod.thisMonth => 'This Month',
    FinancePeriod.lastMonth => 'Last Month',
    FinancePeriod.thisYear => 'This Year',
    FinancePeriod.allTime => 'All Time',
  };

  static FinancePeriod? tryParse(String? raw) {
    if (raw == null) return null;
    switch (raw.trim()) {
      case 'thisMonth':
        return FinancePeriod.thisMonth;
      case 'lastMonth':
        return FinancePeriod.lastMonth;
      case 'thisYear':
        return FinancePeriod.thisYear;
      case 'allTime':
        return FinancePeriod.allTime;
      default:
        return null;
    }
  }

  String toJson() => name;
}
