import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/domain/value_objects/year_month.dart';

/// Monthly spending limit — overall or for one category.
class FinanceBudget {
  const FinanceBudget({
    required this.id,
    required this.name,
    required this.month,
    required this.amountMinor,
    required this.currencyCode,
    required this.warningThresholdBasisPoints,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.archivedAt,
  });

  final String id;
  final String name;

  /// Null = overall monthly budget.
  final String? categoryId;
  final YearMonth month;
  final MoneyMinor amountMinor;
  final String currencyCode;

  /// 0–10000. e.g. 8000 = warn at 80% spent.
  final int warningThresholdBasisPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isOverall => categoryId == null || categoryId!.isEmpty;
  bool get isArchived => archivedAt != null;

  FinanceBudget copyWith({
    String? name,
    String? categoryId,
    YearMonth? month,
    MoneyMinor? amountMinor,
    String? currencyCode,
    int? warningThresholdBasisPoints,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    bool clearCategoryId = false,
  }) {
    return FinanceBudget(
      id: id,
      name: name ?? this.name,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      month: month ?? this.month,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      warningThresholdBasisPoints:
          warningThresholdBasisPoints ?? this.warningThresholdBasisPoints,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'month': month.toIso8601String(),
    'amountMinor': amountMinor.toJson(),
    'currencyCode': currencyCode,
    'warningThresholdBasisPoints': warningThresholdBasisPoints,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'archivedAt': archivedAt?.toUtc().toIso8601String(),
  };

  static FinanceBudget? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final name = json['name'] as String?;
      final month = YearMonth.tryParse(json['month'] as String?);
      final amount = MoneyMinor.tryParse(json['amountMinor']);
      final currency = (json['currencyCode'] as String?)?.trim().toUpperCase();
      final threshold =
          (json['warningThresholdBasisPoints'] as num?)?.toInt() ?? 8000;
      final createdAt = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updatedAt = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          id.isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          month == null ||
          amount == null ||
          currency == null ||
          currency.length != 3 ||
          createdAt == null ||
          updatedAt == null) {
        return null;
      }
      if (amount.value <= BigInt.zero) return null;
      if (threshold < 0 || threshold > 10000) return null;
      final categoryId = (json['categoryId'] as String?)?.trim();
      DateTime? archivedAt;
      final rawArchived = json['archivedAt'];
      if (rawArchived is String && rawArchived.isNotEmpty) {
        archivedAt = DateTime.tryParse(rawArchived)?.toLocal();
      }
      return FinanceBudget(
        id: id,
        name: name.trim(),
        categoryId: (categoryId == null || categoryId.isEmpty)
            ? null
            : categoryId,
        month: month,
        amountMinor: amount,
        currencyCode: currency,
        warningThresholdBasisPoints: threshold,
        createdAt: createdAt,
        updatedAt: updatedAt,
        archivedAt: archivedAt,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Derived budget progress for one [FinanceBudget].
class FinanceBudgetProgress {
  const FinanceBudgetProgress({required this.budget, required this.spentMinor});

  final FinanceBudget budget;
  final MoneyMinor spentMinor;

  /// Remaining minor units (negative when overspent).
  BigInt get remainingSigned => budget.amountMinor.value - spentMinor.value;

  bool get isOverspent => spentMinor.value > budget.amountMinor.value;

  /// 0–10000+ (can exceed 100% when overspent).
  int get spentBasisPoints {
    if (budget.amountMinor.value == BigInt.zero) return 0;
    return ((spentMinor.value * BigInt.from(10000)) ~/ budget.amountMinor.value)
        .toInt();
  }

  bool get isAtOrAboveWarning =>
      spentBasisPoints >= budget.warningThresholdBasisPoints;
}
