class FinanceSummary {
  const FinanceSummary({
    required this.balanceLabel,
    required this.spentTodayLabel,
    required this.envelopeLabel,
    required this.incomeLabel,
    required this.expensesLabel,
  });

  final String balanceLabel;
  final String spentTodayLabel;
  final String envelopeLabel;
  final String incomeLabel;
  final String expensesLabel;

  static const empty = FinanceSummary(
    balanceLabel: '—',
    spentTodayLabel: '—',
    envelopeLabel: 'No envelopes',
    incomeLabel: '—',
    expensesLabel: '—',
  );
}
