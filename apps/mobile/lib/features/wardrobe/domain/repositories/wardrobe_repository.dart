import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/wardrobe_enums.dart';
import '../entities/wardrobe_models.dart';

abstract class WardrobeRepository {
  Stream<List<WardrobeItem>> watchItems();
  Future<List<WardrobeItem>> getItems();
  Future<WardrobeItem?> getItem(String id);
  Future<WardrobeItem> createItem(WardrobeItem item);
  Future<WardrobeItem> updateItem(WardrobeItem item);
  Future<void> archiveItem(String id);
  Future<void> restoreItem(String id);
  Future<void> deleteItem(String id);
  Future<void> setFavorite(String id, bool isFavorite);
  Future<void> updateStatus(String id, WardrobeItemStatus status);

  Stream<List<Outfit>> watchOutfits();
  Future<List<Outfit>> getOutfits();
  Future<Outfit?> getOutfit(String id);
  Future<Outfit> createOutfit(Outfit outfit);
  Future<Outfit> updateOutfit(Outfit outfit);
  Future<void> archiveOutfit(String id);
  Future<void> restoreOutfit(String id);
  Future<void> deleteOutfit(String id);

  Stream<List<OutfitPlan>> watchOutfitPlans();
  Future<List<OutfitPlan>> getPlansForDateRange({
    required LocalDate start,
    required LocalDate endInclusive,
  });
  Future<OutfitPlan?> getPlanForCalendarEvent(String eventId);
  Future<OutfitPlan> createOutfitPlan(OutfitPlan plan, {bool replace = false});
  Future<OutfitPlan> updateOutfitPlan(OutfitPlan plan);
  Future<void> deleteOutfitPlan(String id);

  Stream<List<WearRecord>> watchWearRecords();
  Future<List<WearRecord>> getWearRecords();
  Future<WearRecord> recordWear(WearRecord record);
  Future<WearRecord> updateWearRecord(WearRecord record);
  Future<void> deleteWearRecord(String id);
  Future<List<WearRecord>> getRecentWearForItem(String itemId);
  Future<int> getWearCountForItem(String itemId);

  Future<List<OutfitSuggestion>> getSuggestedOutfits(
    OutfitSuggestionRequest request,
  );

  Future<void> refresh();
  Future<int> countExportableRecords();
  Future<Map<String, Object?>> exportLocalRecords();
  Future<({int records, int files})> deleteLocalRecords();
}
