import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/wardrobe_enums.dart';
import '../entities/wardrobe_models.dart';
import 'outfit_validation_service.dart';

/// Deterministic, rule-based outfit suggestions. Never random. Never AI.
class OutfitSuggestionService {
  const OutfitSuggestionService({
    this.validation = const OutfitValidationService(),
  });

  final OutfitValidationService validation;

  List<OutfitSuggestion> suggest({
    required OutfitSuggestionRequest request,
    required List<WardrobeItem> items,
    required List<WearRecord> wearRecords,
    required List<Outfit> savedOutfits,
  }) {
    final available = items
        .where(
          (item) =>
              !item.isArchived &&
              item.status.canBeWorn &&
              !request.excludedItemIds.contains(item.id),
        )
        .toList(growable: false);
    if (available.isEmpty) return const [];

    final lastWorn = <String, LocalDate>{};
    for (final record in wearRecords) {
      for (final id in record.itemIds) {
        final existing = lastWorn[id];
        if (existing == null || record.localDate.isAfter(existing)) {
          lastWorn[id] = record.localDate;
        }
      }
    }

    final candidates = <OutfitSuggestion>[];
    for (final outfit in savedOutfits.where((o) => !o.isArchived)) {
      final suggestion = _score(
        itemIds: outfit.itemIds,
        request: request,
        items: available,
        allItems: items,
        lastWorn: lastWorn,
        savedName: outfit.name,
      );
      if (suggestion != null) candidates.add(suggestion);
    }

    final generated = _generateCombinations(available, request);
    for (final ids in generated) {
      final suggestion = _score(
        itemIds: ids,
        request: request,
        items: available,
        allItems: items,
        lastWorn: lastWorn,
      );
      if (suggestion != null) candidates.add(suggestion);
    }

    final unique = <String, OutfitSuggestion>{};
    for (final candidate in candidates) {
      final key = ([...candidate.itemIds]..sort()).join('|');
      final existing = unique[key];
      if (existing == null || candidate.score > existing.score) {
        unique[key] = candidate;
      }
    }
    final ranked = unique.values.toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return a.itemIds.join().compareTo(b.itemIds.join());
      });
    final limit = request.maximumSuggestions <= 0
        ? 3
        : request.maximumSuggestions;
    return ranked.take(limit).toList(growable: false);
  }

  List<String> missingCategories({
    required List<WardrobeItem> items,
    required DressCode dressCode,
  }) {
    final available = items.where(
      (item) => !item.isArchived && item.status.canBeWorn,
    );
    final cats = available.map((i) => i.category).toSet();
    final missing = <String>[];
    final hasOnePiece = cats.any((c) => c.isOnePiece);
    if (!hasOnePiece) {
      if (!cats.contains(WardrobeItemCategory.tops)) missing.add('Tops');
      if (!cats.contains(WardrobeItemCategory.bottoms)) missing.add('Bottoms');
    }
    if (dressCode == DressCode.businessFormal ||
        dressCode == DressCode.formal) {
      if (!cats.contains(WardrobeItemCategory.outerwear) &&
          !cats.contains(WardrobeItemCategory.formalWear)) {
        missing.add('Outerwear or formal wear');
      }
    }
    if (dressCode == DressCode.athletic &&
        !cats.contains(WardrobeItemCategory.activewear)) {
      missing.add('Activewear');
    }
    return missing;
  }

  OutfitSuggestion? _score({
    required List<String> itemIds,
    required OutfitSuggestionRequest request,
    required List<WardrobeItem> items,
    required List<WardrobeItem> allItems,
    required Map<String, LocalDate> lastWorn,
    String? savedName,
  }) {
    final byId = {for (final item in allItems) item.id: item};
    final issues = validation.validate(
      itemIds: itemIds,
      itemsById: byId,
      dressCode: request.dressCode,
      occasions: [request.occasion],
    );
    if (issues.contains(OutfitValidationIssue.missingItems) ||
        issues.contains(OutfitValidationIssue.archivedOrUnavailable) ||
        issues.contains(OutfitValidationIssue.accessoriesOnly) ||
        issues.contains(OutfitValidationIssue.coverageIncomplete) ||
        issues.contains(OutfitValidationIssue.emptyOutfit) ||
        issues.contains(OutfitValidationIssue.duplicateItems)) {
      return null;
    }
    final resolved = [
      for (final id in itemIds)
        if (byId[id] != null) byId[id]!,
    ];
    var score = 50;
    final reasons = <String>[
      'Suggested from your available items.',
      if (savedName != null) 'Based on saved outfit “$savedName”.',
    ];
    final warnings = [for (final issue in issues) issue.userMessage];

    final occasionMatch = resolved.every(
      (item) =>
          item.occasions.isEmpty || item.occasions.contains(request.occasion),
    );
    if (occasionMatch) {
      score += 20;
      reasons.add('Occasion matches ${request.occasion.label}.');
    } else {
      score -= 15;
    }

    final dressMatch = resolved.every(
      (item) =>
          item.dressCodes.isEmpty ||
          item.dressCodes.contains(request.dressCode),
    );
    if (dressMatch) {
      score += 20;
      reasons.add('Dress code matches ${request.dressCode.label}.');
    } else {
      score -= 15;
    }

    var climateMatch = true;
    if (request.climateTags.isNotEmpty) {
      climateMatch = resolved.every((item) {
        if (item.seasons.contains(WardrobeSeason.allSeason) ||
            item.seasons.isEmpty) {
          return true;
        }
        return item.seasons.any(
          (season) => request.climateTags.any(
            (tag) => _seasonMatchesClimate(season, tag),
          ),
        );
      });
      if (climateMatch) {
        score += 8;
      } else {
        score -= 6;
        climateMatch = false;
      }
    }

    final colors = resolved.expand((i) => i.colorKeys).toSet();
    final colorOk = _colorsCompatible(colors);
    if (colorOk) {
      score += 8;
    } else {
      score -= 8;
    }
    if (request.preferredColorKeys.any(colors.contains)) {
      score += 6;
      reasons.add('Includes a preferred color.');
    }

    var penalty = 0;
    final avoid = request.avoidRecentlyWornDays;
    if (avoid > 0) {
      for (final item in resolved) {
        final worn = lastWorn[item.id];
        if (worn == null) continue;
        final delta = request.localDate
            .toDateTimeUtc()
            .difference(worn.toDateTimeUtc())
            .inDays;
        if (delta < avoid) {
          penalty += (avoid - delta) * 2;
        }
      }
    }
    score -= penalty;
    for (final item in resolved) {
      if (item.isFavorite) score += 3;
    }

    return OutfitSuggestion(
      itemIds: List.unmodifiable(itemIds),
      score: score,
      reasons: reasons,
      warnings: warnings,
      occasionMatch: occasionMatch,
      dressCodeMatch: dressMatch,
      climateMatch: climateMatch,
      colorCompatibility: colorOk,
      recentWearPenalty: penalty,
    );
  }

  bool _seasonMatchesClimate(WardrobeSeason season, ClimateTag tag) {
    return switch (tag) {
      ClimateTag.hot || ClimateTag.warm =>
        season == WardrobeSeason.summer || season == WardrobeSeason.spring,
      ClimateTag.mild =>
        season == WardrobeSeason.spring || season == WardrobeSeason.autumn,
      ClimateTag.cool || ClimateTag.cold =>
        season == WardrobeSeason.winter || season == WardrobeSeason.autumn,
      ClimateTag.rain ||
      ClimateTag.dry ||
      ClimateTag.indoor ||
      ClimateTag.outdoor => true,
    };
  }

  bool _colorsCompatible(Set<WardrobeColorKey> colors) {
    if (colors.length <= 2) return true;
    const neutrals = {
      WardrobeColorKey.black,
      WardrobeColorKey.white,
      WardrobeColorKey.navy,
      WardrobeColorKey.gray,
      WardrobeColorKey.beige,
      WardrobeColorKey.brown,
      WardrobeColorKey.cream,
    };
    final accents = colors.difference(neutrals);
    return accents.length <= 2;
  }

  List<List<String>> _generateCombinations(
    List<WardrobeItem> available,
    OutfitSuggestionRequest request,
  ) {
    bool matches(WardrobeItem item) {
      final occasionOk =
          item.occasions.isEmpty || item.occasions.contains(request.occasion);
      final dressOk =
          item.dressCodes.isEmpty ||
          item.dressCodes.contains(request.dressCode);
      return occasionOk && dressOk;
    }

    final pool = available.where(matches).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final dresses = pool.where((i) => i.category.isOnePiece).toList();
    final tops = pool
        .where((i) => i.category == WardrobeItemCategory.tops)
        .toList();
    final bottoms = pool
        .where((i) => i.category == WardrobeItemCategory.bottoms)
        .toList();
    final shoes = pool
        .where((i) => i.category == WardrobeItemCategory.footwear)
        .toList();
    final outer = pool
        .where((i) => i.category == WardrobeItemCategory.outerwear)
        .toList();

    final results = <List<String>>[];
    void addCombo(List<WardrobeItem> pieces) {
      if (pieces.isEmpty) return;
      results.add(pieces.map((p) => p.id).toList(growable: false));
    }

    for (final dress in dresses.take(4)) {
      addCombo([
        dress,
        if (shoes.isNotEmpty) shoes.first,
        if (outer.isNotEmpty) outer.first,
      ]);
    }
    for (final top in tops.take(4)) {
      for (final bottom in bottoms.take(4)) {
        addCombo([
          top,
          bottom,
          if (shoes.isNotEmpty) shoes.first,
          if (request.dressCode == DressCode.businessFormal && outer.isNotEmpty)
            outer.first,
        ]);
      }
    }
    return results;
  }
}
