import '../entities/wardrobe_enums.dart';
import '../entities/wardrobe_models.dart';

class OutfitValidationService {
  const OutfitValidationService();

  List<OutfitValidationIssue> validate({
    required List<String> itemIds,
    required Map<String, WardrobeItem> itemsById,
    required DressCode dressCode,
    required List<WardrobeOccasion> occasions,
    bool allowHistoricalUnavailable = false,
  }) {
    final issues = <OutfitValidationIssue>[];
    if (itemIds.isEmpty) {
      return [OutfitValidationIssue.emptyOutfit];
    }
    if (itemIds.toSet().length != itemIds.length) {
      issues.add(OutfitValidationIssue.duplicateItems);
    }
    final resolved = <WardrobeItem>[];
    for (final id in itemIds.toSet()) {
      final item = itemsById[id];
      if (item == null) {
        issues.add(OutfitValidationIssue.missingItems);
        continue;
      }
      resolved.add(item);
      if (!allowHistoricalUnavailable &&
          (item.isArchived || !item.status.canBeWorn)) {
        issues.add(OutfitValidationIssue.archivedOrUnavailable);
      }
    }
    if (resolved.isEmpty) return issues;

    final hasPrimary = resolved.any((i) => i.category.isPrimaryClothing);
    if (!hasPrimary) {
      issues.add(OutfitValidationIssue.accessoriesOnly);
    }

    final hasOnePiece = resolved.any((i) => i.category.isOnePiece);
    final hasTop = resolved.any((i) => i.category == WardrobeItemCategory.tops);
    final hasBottom = resolved.any(
      (i) => i.category == WardrobeItemCategory.bottoms,
    );
    if (!hasOnePiece && !(hasTop && hasBottom) && resolved.length < 2) {
      issues.add(OutfitValidationIssue.coverageIncomplete);
    }

    if (occasions.isNotEmpty) {
      final ok = resolved.every(
        (item) =>
            item.occasions.isEmpty || item.occasions.any(occasions.contains),
      );
      if (!ok) issues.add(OutfitValidationIssue.occasionMismatch);
    }
    final dressOk = resolved.every(
      (item) => item.dressCodes.isEmpty || item.dressCodes.contains(dressCode),
    );
    if (!dressOk) issues.add(OutfitValidationIssue.dressCodeMismatch);

    return issues.toSet().toList(growable: false);
  }
}
