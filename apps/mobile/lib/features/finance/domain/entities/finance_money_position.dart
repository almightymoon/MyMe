import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/domain/value_objects/money_minor.dart';

/// Whether this row is money the user owes, or money someone owes them.
enum MoneyPositionDirection {
  iOwe,
  owedToMe;

  String get label => switch (this) {
    MoneyPositionDirection.iOwe => 'I owe',
    MoneyPositionDirection.owedToMe => 'Owed to me',
  };

  static MoneyPositionDirection? tryParse(String? raw) {
    switch (raw?.trim()) {
      case 'iOwe':
        return MoneyPositionDirection.iOwe;
      case 'owedToMe':
        return MoneyPositionDirection.owedToMe;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Derived lifecycle for a [FinanceMoneyPosition]. Never stored.
enum MoneyPositionStatus {
  overdue,
  open,
  settled;

  String get label => switch (this) {
    MoneyPositionStatus.overdue => 'Overdue',
    MoneyPositionStatus.open => 'Open',
    MoneyPositionStatus.settled => 'Settled',
  };
}

/// One payment against a money-owed position. Cannot exceed remaining.
class FinanceMoneyPayment {
  const FinanceMoneyPayment({
    required this.id,
    required this.amountMinor,
    required this.paidAt,
    this.note,
  });

  final String id;
  final MoneyMinor amountMinor;
  final DateTime paidAt;
  final String? note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountMinor': amountMinor.toJson(),
    'paidAt': paidAt.toUtc().toIso8601String(),
    'note': note,
  };

  static FinanceMoneyPayment? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final amount = MoneyMinor.fromJson(json['amountMinor']);
      final paidAt = DateTime.tryParse(
        json['paidAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          id.isEmpty ||
          amount == null ||
          !amount.isPositive ||
          paidAt == null) {
        return null;
      }
      final note = (json['note'] as String?)?.trim();
      return FinanceMoneyPayment(
        id: id,
        amountMinor: amount,
        paidAt: paidAt,
        note: (note == null || note.isEmpty) ? null : note,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Simple money-owed ledger row. No interest, no amortization.
class FinanceMoneyPosition {
  const FinanceMoneyPosition({
    required this.id,
    required this.direction,
    required this.counterparty,
    required this.originalAmountMinor,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.dueDate,
    this.payments = const [],
  });

  final String id;
  final MoneyPositionDirection direction;
  final String counterparty;
  final MoneyMinor originalAmountMinor;
  final String currencyCode;
  final String? note;
  final LocalDate? dueDate;
  final List<FinanceMoneyPayment> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoneyMinor get paidMinor {
    var total = MoneyMinor.zero;
    for (final payment in payments) {
      total += payment.amountMinor;
    }
    return total;
  }

  MoneyMinor get remainingMinor => originalAmountMinor - paidMinor;

  bool get isSettled => remainingMinor.isZero;

  bool canAcceptPayment(MoneyMinor amount) =>
      amount.isPositive && amount <= remainingMinor;

  MoneyPositionStatus statusAt(LocalDate today) {
    if (isSettled) return MoneyPositionStatus.settled;
    if (dueDate != null && dueDate!.isBefore(today)) {
      return MoneyPositionStatus.overdue;
    }
    return MoneyPositionStatus.open;
  }

  FinanceMoneyPosition copyWith({
    MoneyPositionDirection? direction,
    String? counterparty,
    MoneyMinor? originalAmountMinor,
    String? currencyCode,
    String? note,
    LocalDate? dueDate,
    List<FinanceMoneyPayment>? payments,
    DateTime? updatedAt,
    bool clearNote = false,
    bool clearDueDate = false,
  }) {
    return FinanceMoneyPosition(
      id: id,
      direction: direction ?? this.direction,
      counterparty: counterparty ?? this.counterparty,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      note: clearNote ? null : (note ?? this.note),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      payments: payments ?? this.payments,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'direction': direction.toJson(),
    'counterparty': counterparty,
    'originalAmountMinor': originalAmountMinor.toJson(),
    'currencyCode': currencyCode,
    'note': note,
    'dueDate': dueDate?.toIso8601String(),
    'payments': payments.map((p) => p.toJson()).toList(growable: false),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  static FinanceMoneyPosition? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final direction = MoneyPositionDirection.tryParse(
        json['direction'] as String?,
      );
      final counterparty = (json['counterparty'] as String?)?.trim();
      final amount = MoneyMinor.fromJson(json['originalAmountMinor']);
      final currency = (json['currencyCode'] as String?)?.trim().toUpperCase();
      final createdAt = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updatedAt = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          id.isEmpty ||
          direction == null ||
          counterparty == null ||
          counterparty.isEmpty ||
          amount == null ||
          !amount.isPositive ||
          currency == null ||
          currency.length != 3 ||
          createdAt == null ||
          updatedAt == null) {
        return null;
      }
      final payments = <FinanceMoneyPayment>[];
      final rawPayments = json['payments'];
      if (rawPayments is List) {
        for (final item in rawPayments) {
          final parsed = item is Map<String, dynamic>
              ? FinanceMoneyPayment.fromJson(item)
              : item is Map
              ? FinanceMoneyPayment.fromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) payments.add(parsed);
        }
      }
      var paid = MoneyMinor.zero;
      for (final payment in payments) {
        paid += payment.amountMinor;
      }
      if (paid > amount) return null;

      final note = (json['note'] as String?)?.trim();
      LocalDate? dueDate;
      final rawDue = json['dueDate'];
      if (rawDue is String && rawDue.isNotEmpty) {
        dueDate = LocalDate.tryParse(rawDue);
      }
      return FinanceMoneyPosition(
        id: id,
        direction: direction,
        counterparty: counterparty,
        originalAmountMinor: amount,
        currencyCode: currency,
        note: (note == null || note.isEmpty) ? null : note,
        dueDate: dueDate,
        payments: List<FinanceMoneyPayment>.unmodifiable(payments),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Aggregated remaining balances for overview cards.
class MoneyOwedTotals {
  const MoneyOwedTotals({
    required this.iOweRemaining,
    required this.owedToMeRemaining,
    required this.openCount,
    required this.overdueCount,
    required this.currencyCode,
  });

  final MoneyMinor iOweRemaining;
  final MoneyMinor owedToMeRemaining;
  final int openCount;
  final int overdueCount;
  final String currencyCode;

  bool get isEmpty => openCount == 0 && overdueCount == 0;

  static MoneyOwedTotals fromPositions(
    List<FinanceMoneyPosition> positions, {
    required String currencyCode,
    LocalDate? asOf,
  }) {
    final today = asOf ?? LocalDate.fromDateTime(DateTime.now());
    var iOwe = MoneyMinor.zero;
    var owedToMe = MoneyMinor.zero;
    var open = 0;
    var overdue = 0;
    for (final position in positions) {
      final status = position.statusAt(today);
      if (status == MoneyPositionStatus.settled) continue;
      open += 1;
      if (status == MoneyPositionStatus.overdue) overdue += 1;
      if (position.direction == MoneyPositionDirection.iOwe) {
        iOwe += position.remainingMinor;
      } else {
        owedToMe += position.remainingMinor;
      }
    }
    return MoneyOwedTotals(
      iOweRemaining: iOwe,
      owedToMeRemaining: owedToMe,
      openCount: open,
      overdueCount: overdue,
      currencyCode: currencyCode,
    );
  }
}
