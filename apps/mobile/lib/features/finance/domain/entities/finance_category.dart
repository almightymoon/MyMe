import 'finance_enums.dart';

/// User-facing spend / income bucket.
class FinanceCategory {
  const FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.isCustom,
    this.isArchived = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String iconKey;
  final bool isCustom;
  final bool isArchived;
  final DateTime? createdAt;

  bool get isBuiltIn => !isCustom;

  FinanceCategory copyWith({
    String? name,
    TransactionType? type,
    String? iconKey,
    bool? isArchived,
  }) {
    return FinanceCategory(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      isCustom: isCustom,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toJson(),
    'iconKey': iconKey,
    'isCustom': isCustom,
    'isArchived': isArchived,
    'createdAt': createdAt?.toUtc().toIso8601String(),
  };

  static FinanceCategory? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final name = json['name'] as String?;
      final type = TransactionType.tryParse(json['type'] as String?);
      final iconKey = json['iconKey'] as String? ?? 'other';
      final isCustom = json['isCustom'] == true;
      if (id == null ||
          id.isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          type == null) {
        return null;
      }
      DateTime? createdAt;
      final rawCreated = json['createdAt'];
      if (rawCreated is String && rawCreated.isNotEmpty) {
        createdAt = DateTime.tryParse(rawCreated)?.toLocal();
      }
      return FinanceCategory(
        id: id,
        name: name.trim(),
        type: type,
        iconKey: iconKey,
        isCustom: isCustom,
        isArchived: json['isArchived'] == true,
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }
}
