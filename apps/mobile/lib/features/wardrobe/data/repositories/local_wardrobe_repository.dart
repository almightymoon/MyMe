import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/wardrobe_enums.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../domain/services/outfit_suggestion_service.dart';
import '../../domain/services/outfit_validation_service.dart';
import '../../domain/services/wardrobe_image_store.dart';

class LocalWardrobeRepository implements WardrobeRepository {
  LocalWardrobeRepository({
    required this.prefs,
    required this.imageStore,
    this.clock = const SystemAppClock(),
    this.suggestionService = const OutfitSuggestionService(),
    this.validation = const OutfitValidationService(),
  });

  static const int schemaVersion = 1;
  static const String storageKey = 'memy_wardrobe_v1';
  static const String initializedKey = 'memy_wardrobe_initialized_v1';

  final SharedPreferences prefs;
  final WardrobeImageStore imageStore;
  final AppClock clock;
  final OutfitSuggestionService suggestionService;
  final OutfitValidationService validation;

  final _itemsController = StreamController<List<WardrobeItem>>.broadcast();
  final _outfitsController = StreamController<List<Outfit>>.broadcast();
  final _plansController = StreamController<List<OutfitPlan>>.broadcast();
  final _wearController = StreamController<List<WearRecord>>.broadcast();
  Future<void>? _initFuture;

  List<WardrobeItem> _items = const [];
  List<Outfit> _outfits = const [];
  List<OutfitPlan> _plans = const [];
  List<WearRecord> _wear = const [];

  Future<void> ensureInitialized() => _initFuture ??= _initialize();

  Future<void> _requireReady() => ensureInitialized();

  Future<void> _initialize() async {
    final initialized = prefs.getBool(initializedKey) ?? false;
    if (!initialized) {
      await _persist();
      await prefs.setBool(initializedKey, true);
      return;
    }
    _readFromDisk();
  }

  void _readFromDisk() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version != 0 && version != schemaVersion) return;
      _items = _parseList(map['items'], WardrobeItem.fromJson);
      _outfits = _parseList(map['outfits'], Outfit.fromJson);
      _plans = _parseList(map['plans'], OutfitPlan.fromJson);
      _wear = _parseList(map['wearRecords'], WearRecord.fromJson);
    } catch (_) {
      _items = const [];
      _outfits = const [];
      _plans = const [];
      _wear = const [];
    }
  }

  List<T> _parseList<T>(Object? raw, T? Function(Map<String, dynamic>?) parse) {
    if (raw is! List) return const [];
    final out = <T>[];
    for (final item in raw) {
      final parsed = item is Map
          ? parse(Map<String, dynamic>.from(item))
          : null;
      if (parsed != null) out.add(parsed);
    }
    return List.unmodifiable(out);
  }

  Future<void> _persist() async {
    await prefs.setString(
      storageKey,
      jsonEncode({
        'schemaVersion': schemaVersion,
        'items': _items.map((e) => e.toJson()).toList(),
        'outfits': _outfits.map((e) => e.toJson()).toList(),
        'plans': _plans.map((e) => e.toJson()).toList(),
        'wearRecords': _wear.map((e) => e.toJson()).toList(),
      }),
    );
    _emit();
  }

  void _emit() {
    if (!_itemsController.isClosed) {
      _itemsController.add(List.unmodifiable(_items));
    }
    if (!_outfitsController.isClosed) {
      _outfitsController.add(List.unmodifiable(_outfits));
    }
    if (!_plansController.isClosed) {
      _plansController.add(List.unmodifiable(_plans));
    }
    if (!_wearController.isClosed) {
      _wearController.add(List.unmodifiable(_wear));
    }
  }

  @override
  Stream<List<WardrobeItem>> watchItems() async* {
    await _requireReady();
    yield List.unmodifiable(_items);
    yield* _itemsController.stream;
  }

  @override
  Future<List<WardrobeItem>> getItems() async {
    await _requireReady();
    return List.unmodifiable(_items);
  }

  @override
  Future<WardrobeItem?> getItem(String id) async {
    await _requireReady();
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<WardrobeItem> createItem(WardrobeItem item) async {
    await _requireReady();
    _items = List.unmodifiable([..._items, item]);
    await _persist();
    return item;
  }

  @override
  Future<WardrobeItem> updateItem(WardrobeItem item) async {
    await _requireReady();
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index < 0) throw AppException.notFound('Item not found.');
    final next = [..._items];
    next[index] = item;
    _items = List.unmodifiable(next);
    await _persist();
    return item;
  }

  @override
  Future<void> archiveItem(String id) async {
    final item = await getItem(id);
    if (item == null) throw AppException.notFound('Item not found.');
    await updateItem(
      item.copyWith(
        status: WardrobeItemStatus.archived,
        archivedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> restoreItem(String id) async {
    final item = await getItem(id);
    if (item == null) throw AppException.notFound('Item not found.');
    await updateItem(
      item.copyWith(
        status: WardrobeItemStatus.available,
        updatedAt: DateTime.now(),
        clearArchivedAt: true,
      ),
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await _requireReady();
    final item = await getItem(id);
    if (item == null) throw AppException.notFound('Item not found.');
    _outfits = List.unmodifiable([
      for (final outfit in _outfits)
        outfit.copyWith(
          itemIds: outfit.itemIds.where((other) => other != id).toList(),
          updatedAt: DateTime.now(),
        ),
    ]);
    _items = List.unmodifiable(_items.where((e) => e.id != id));
    await _persist();
    if (item.imageReference != null) {
      await imageStore.deleteImage(item.imageReference!);
    }
  }

  @override
  Future<void> setFavorite(String id, bool isFavorite) async {
    final item = await getItem(id);
    if (item == null) throw AppException.notFound('Item not found.');
    await updateItem(
      item.copyWith(isFavorite: isFavorite, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> updateStatus(String id, WardrobeItemStatus status) async {
    final item = await getItem(id);
    if (item == null) throw AppException.notFound('Item not found.');
    await updateItem(item.copyWith(status: status, updatedAt: DateTime.now()));
  }

  @override
  Stream<List<Outfit>> watchOutfits() async* {
    await _requireReady();
    yield List.unmodifiable(_outfits);
    yield* _outfitsController.stream;
  }

  @override
  Future<List<Outfit>> getOutfits() async {
    await _requireReady();
    return List.unmodifiable(_outfits);
  }

  @override
  Future<Outfit?> getOutfit(String id) async {
    await _requireReady();
    for (final outfit in _outfits) {
      if (outfit.id == id) return outfit;
    }
    return null;
  }

  Map<String, WardrobeItem> get _itemsById => {
    for (final item in _items) item.id: item,
  };

  void _assertOutfit(Outfit outfit) {
    final issues = validation.validate(
      itemIds: outfit.itemIds,
      itemsById: _itemsById,
      dressCode: outfit.dressCode,
      occasions: outfit.occasions,
    );
    if (issues.isNotEmpty) {
      throw AppException.validation(
        issues.first.userMessage,
        code: 'outfitInvalid',
      );
    }
  }

  @override
  Future<Outfit> createOutfit(Outfit outfit) async {
    await _requireReady();
    _assertOutfit(outfit);
    _outfits = List.unmodifiable([..._outfits, outfit]);
    await _persist();
    return outfit;
  }

  @override
  Future<Outfit> updateOutfit(Outfit outfit) async {
    await _requireReady();
    if (!outfit.isArchived) _assertOutfit(outfit);
    final index = _outfits.indexWhere((e) => e.id == outfit.id);
    if (index < 0) throw AppException.notFound('Outfit not found.');
    final next = [..._outfits];
    next[index] = outfit;
    _outfits = List.unmodifiable(next);
    await _persist();
    return outfit;
  }

  @override
  Future<void> archiveOutfit(String id) async {
    final outfit = await getOutfit(id);
    if (outfit == null) throw AppException.notFound('Outfit not found.');
    await updateOutfit(
      outfit.copyWith(archivedAt: DateTime.now(), updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> restoreOutfit(String id) async {
    final outfit = await getOutfit(id);
    if (outfit == null) throw AppException.notFound('Outfit not found.');
    await updateOutfit(
      outfit.copyWith(clearArchivedAt: true, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> deleteOutfit(String id) async {
    await _requireReady();
    _plans = List.unmodifiable(_plans.where((p) => p.outfitId != id));
    _outfits = List.unmodifiable(_outfits.where((o) => o.id != id));
    await _persist();
  }

  @override
  Stream<List<OutfitPlan>> watchOutfitPlans() async* {
    await _requireReady();
    yield List.unmodifiable(_plans);
    yield* _plansController.stream;
  }

  @override
  Future<List<OutfitPlan>> getPlansForDateRange({
    required LocalDate start,
    required LocalDate endInclusive,
  }) async {
    await _requireReady();
    return List.unmodifiable(
      _plans.where(
        (p) =>
            p.localDate.isSameOrAfter(start) &&
            p.localDate.isSameOrBefore(endInclusive),
      ),
    );
  }

  @override
  Future<OutfitPlan?> getPlanForCalendarEvent(String eventId) async {
    await _requireReady();
    for (final plan in _plans) {
      if (plan.calendarEventId == eventId) return plan;
    }
    return null;
  }

  @override
  Future<OutfitPlan> createOutfitPlan(
    OutfitPlan plan, {
    bool replace = false,
  }) async {
    await _requireReady();
    final clash = _plans.where((p) => p.localDate == plan.localDate).toList();
    if (clash.isNotEmpty && !replace) {
      throw AppException.conflict(
        'An outfit is already planned for that date.',
      );
    }
    _plans = List.unmodifiable([
      ..._plans.where((p) => p.localDate != plan.localDate),
      plan,
    ]);
    await _persist();
    return plan;
  }

  @override
  Future<OutfitPlan> updateOutfitPlan(OutfitPlan plan) async {
    await _requireReady();
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index < 0) throw AppException.notFound('Plan not found.');
    final next = [..._plans];
    next[index] = plan;
    _plans = List.unmodifiable(next);
    await _persist();
    return plan;
  }

  @override
  Future<void> deleteOutfitPlan(String id) async {
    await _requireReady();
    _plans = List.unmodifiable(_plans.where((p) => p.id != id));
    await _persist();
  }

  @override
  Stream<List<WearRecord>> watchWearRecords() async* {
    await _requireReady();
    yield List.unmodifiable(_wear);
    yield* _wearController.stream;
  }

  @override
  Future<List<WearRecord>> getWearRecords() async {
    await _requireReady();
    return List.unmodifiable(_wear);
  }

  @override
  Future<WearRecord> recordWear(WearRecord record) async {
    await _requireReady();
    if (record.localDate.isAfter(LocalDate.fromDateTime(clock.now()))) {
      throw AppException.validation('Wear dates cannot be in the future.');
    }
    _wear = List.unmodifiable([..._wear, record]);
    await _persist();
    return record;
  }

  @override
  Future<WearRecord> updateWearRecord(WearRecord record) async {
    await _requireReady();
    final index = _wear.indexWhere((w) => w.id == record.id);
    if (index < 0) throw AppException.notFound('Wear record not found.');
    final next = [..._wear];
    next[index] = record;
    _wear = List.unmodifiable(next);
    await _persist();
    return record;
  }

  @override
  Future<void> deleteWearRecord(String id) async {
    await _requireReady();
    _wear = List.unmodifiable(_wear.where((w) => w.id != id));
    await _persist();
  }

  @override
  Future<List<WearRecord>> getRecentWearForItem(String itemId) async {
    await _requireReady();
    final matches = _wear.where((w) => w.itemIds.contains(itemId)).toList()
      ..sort((a, b) => b.localDate.compareTo(a.localDate));
    return matches;
  }

  @override
  Future<int> getWearCountForItem(String itemId) async {
    return (await getRecentWearForItem(itemId)).length;
  }

  @override
  Future<List<OutfitSuggestion>> getSuggestedOutfits(
    OutfitSuggestionRequest request,
  ) async {
    await _requireReady();
    return suggestionService.suggest(
      request: request,
      items: _items,
      wearRecords: _wear,
      savedOutfits: _outfits,
    );
  }

  @override
  Future<void> refresh() async {
    await _requireReady();
    _readFromDisk();
    _emit();
  }

  @override
  Future<int> countExportableRecords() async {
    await _requireReady();
    return _items.length + _outfits.length + _plans.length + _wear.length;
  }

  @override
  Future<Map<String, Object?>> exportLocalRecords() async {
    await _requireReady();
    return {
      'schemaVersion': schemaVersion,
      'items': _items.map((e) => e.toJson()).toList(),
      'outfits': _outfits.map((e) => e.toJson()).toList(),
      'plans': _plans.map((e) => e.toJson()).toList(),
      'wearRecords': _wear.map((e) => e.toJson()).toList(),
      'imageFilesIncluded': false,
      'warning': 'Wardrobe image files are not included in this export.',
    };
  }

  @override
  Future<({int records, int files})> deleteLocalRecords() async {
    await _requireReady();
    final records = await countExportableRecords();
    _items = const [];
    _outfits = const [];
    _plans = const [];
    _wear = const [];
    await _persist();
    final files = await imageStore.deleteAllImages();
    return (records: records, files: files);
  }

  void dispose() {
    _itemsController.close();
    _outfitsController.close();
    _plansController.close();
    _wearController.close();
  }
}
