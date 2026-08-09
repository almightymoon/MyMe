import '../../../../core/domain/value_objects/money_minor.dart';
import 'finance_enums.dart';

/// A single manual income or expense entry.
class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    required this.occurredAt,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.merchantOrSource,
    this.note,
  });

  final String id;
  final TransactionType type;
  final MoneyMinor amountMinor;
  final String currencyCode;
  final String categoryId;
  final DateTime occurredAt;
  final PaymentMethod paymentMethod;
  final String? merchantOrSource;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinanceTransaction copyWith({
    String? id,
    TransactionType? type,
    MoneyMinor? amountMinor,
    String? currencyCode,
    String? categoryId,
    DateTime? occurredAt,
    PaymentMethod? paymentMethod,
    String? merchantOrSource,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearMerchantOrSource = false,
    bool clearNote = false,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantOrSource: clearMerchantOrSource
          ? null
          : (merchantOrSource ?? this.merchantOrSource),
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'amountMinor': amountMinor.toJson(),
    'currencyCode': currencyCode,
    'categoryId': categoryId,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'paymentMethod': paymentMethod.toJson(),
    'merchantOrSource': merchantOrSource,
    'note': note,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  /// Returns `null` when the entry is corrupt / incomplete.
  static FinanceTransaction? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final type = TransactionType.tryParse(json['type'] as String?);
      final amount = MoneyMinor.fromJson(json['amountMinor']);
      final currency = (json['currencyCode'] as String?)?.trim().toUpperCase();
      final categoryId = json['categoryId'] as String?;
      final occurredAt = DateTime.tryParse(json['occurredAt'] as String? ?? '');
      final method = PaymentMethod.tryParse(json['paymentMethod'] as String?);
      final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
      final updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '');
      if (id == null ||
          id.isEmpty ||
          type == null ||
          amount == null ||
          currency == null ||
          currency.length != 3 ||
          categoryId == null ||
          categoryId.isEmpty ||
          occurredAt == null ||
          method == null ||
          createdAt == null ||
          updatedAt == null) {
        return null;
      }
      final merchant = json['merchantOrSource'] as String?;
      final note = json['note'] as String?;
      return FinanceTransaction(
        id: id,
        type: type,
        amountMinor: amount,
        currencyCode: currency,
        categoryId: categoryId,
        occurredAt: occurredAt.toLocal(),
        paymentMethod: method,
        merchantOrSource: merchant?.trim().isEmpty == true
            ? null
            : merchant?.trim(),
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        createdAt: createdAt.toLocal(),
        updatedAt: updatedAt.toLocal(),
      );
    } catch (_) {
      return null;
    }
  }
}
