import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/wardrobe/data/repositories/local_wardrobe_repository.dart';
import 'package:memy/features/wardrobe/data/storage/local_wardrobe_image_store.dart';
import 'package:memy/features/wardrobe/domain/entities/wardrobe_enums.dart';
import 'package:memy/features/wardrobe/domain/entities/wardrobe_models.dart';
import 'package:memy/features/wardrobe/domain/services/outfit_suggestion_service.dart';
import 'package:memy/features/wardrobe/domain/services/outfit_validation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

WardrobeItem _item({
  required String id,
  required String name,
  required WardrobeItemCategory category,
  List<WardrobeOccasion> occasions = const [WardrobeOccasion.business],
  List<DressCode> dressCodes = const [DressCode.businessFormal],
  WardrobeItemStatus status = WardrobeItemStatus.available,
  bool favorite = false,
}) {
  final now = DateTime(2026, 8, 11);
  return WardrobeItem(
    id: id,
    name: name,
    category: category,
    status: status,
    isFavorite: favorite,
    colorKeys: const [WardrobeColorKey.navy, WardrobeColorKey.white],
    seasons: const [WardrobeSeason.allSeason],
    occasions: occasions,
    dressCodes: dressCodes,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('outfit validation covers one-piece and rejects accessories-only', () {
    const service = OutfitValidationService();
    final dress = _item(
      id: 'dress',
      name: 'Dress',
      category: WardrobeItemCategory.dresses,
      occasions: const [WardrobeOccasion.formal],
      dressCodes: const [DressCode.formal],
    );
    expect(
      service.validate(
        itemIds: [dress.id],
        itemsById: {dress.id: dress},
        dressCode: DressCode.formal,
        occasions: const [WardrobeOccasion.formal],
      ),
      isEmpty,
    );

    final bag = _item(
      id: 'bag',
      name: 'Bag',
      category: WardrobeItemCategory.bags,
    );
    expect(
      service.validate(
        itemIds: [bag.id],
        itemsById: {bag.id: bag},
        dressCode: DressCode.casual,
        occasions: const [WardrobeOccasion.casual],
      ),
      contains(OutfitValidationIssue.accessoriesOnly),
    );
  });

  test('suggestions are deterministic and exclude laundry', () {
    const service = OutfitSuggestionService();
    final items = [
      _item(
        id: 'blazer',
        name: 'Navy Blazer',
        category: WardrobeItemCategory.outerwear,
      ),
      _item(
        id: 'shirt',
        name: 'White Shirt',
        category: WardrobeItemCategory.tops,
      ),
      _item(
        id: 'trousers',
        name: 'Black Trousers',
        category: WardrobeItemCategory.bottoms,
      ),
      _item(
        id: 'shoes',
        name: 'Black Shoes',
        category: WardrobeItemCategory.footwear,
      ),
      _item(
        id: 'tee',
        name: 'Gym tee',
        category: WardrobeItemCategory.activewear,
        status: WardrobeItemStatus.inLaundry,
        occasions: const [WardrobeOccasion.workout],
        dressCodes: const [DressCode.athletic],
      ),
    ];
    final request = OutfitSuggestionRequest(
      localDate: LocalDate(2026, 8, 11),
      occasion: WardrobeOccasion.business,
      dressCode: DressCode.businessFormal,
    );
    final first = service.suggest(
      request: request,
      items: items,
      wearRecords: const [],
      savedOutfits: const [],
    );
    final second = service.suggest(
      request: request,
      items: items,
      wearRecords: const [],
      savedOutfits: const [],
    );
    expect(first, isNotEmpty);
    expect(
      first.map((s) => s.itemIds.join('|')).toList(),
      second.map((s) => s.itemIds.join('|')).toList(),
    );
    expect(
      first.first.reasons,
      contains('Suggested from your available items.'),
    );
    expect(first.every((s) => !s.itemIds.contains('tee')), isTrue);

    final winterCoat = _item(
      id: 'coat',
      name: 'Winter coat',
      category: WardrobeItemCategory.outerwear,
    ).copyWith(seasons: const [WardrobeSeason.winter]);
    final hotRequest = OutfitSuggestionRequest(
      localDate: LocalDate(2026, 8, 11),
      occasion: WardrobeOccasion.business,
      dressCode: DressCode.businessFormal,
      climateTags: const [ClimateTag.hot],
    );
    final hot = service.suggest(
      request: hotRequest,
      items: [...items, winterCoat],
      wearRecords: const [],
      savedOutfits: const [],
    );
    expect(
      hot.every((s) => !s.itemIds.contains('coat') || !s.climateMatch),
      isTrue,
    );
  });

  test('image store re-encodes and uses random filenames', () async {
    final root = await Directory.systemTemp.createTemp('wardrobe_img');
    var n = 0;
    final store = LocalWardrobeImageStore(
      documentsDirectory: () async => root,
      idGenerator: () => 'id-${n++}',
    );
    final image = img.Image(width: 32, height: 32);
    final source = File('${root.path}/source.png');
    await source.writeAsBytes(img.encodePng(image));
    final ref = await store.importFromPickedFile(source.path);
    expect(ref.relativeOriginalPath.contains('source'), isFalse);
    expect(ref.relativeOriginalPath.startsWith('/'), isFalse);
    expect(await store.getThumbnailFile(ref), isNotNull);
    expect(await store.calculateStorageUsage(), greaterThan(0));
    await store.deleteImage(ref);
    expect(await store.getOriginalFile(ref), isNull);
  });

  test('local wardrobe repository persists and does not reseed', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final root = await Directory.systemTemp.createTemp('wardrobe_repo');
    final store = LocalWardrobeImageStore(
      documentsDirectory: () async => root,
      idGenerator: () => 'img-1',
    );
    final repo = LocalWardrobeRepository(prefs: prefs, imageStore: store);
    final blazer = _item(
      id: 'blazer',
      name: 'Navy Blazer',
      category: WardrobeItemCategory.outerwear,
    );
    final shirt = _item(
      id: 'shirt',
      name: 'White Shirt',
      category: WardrobeItemCategory.tops,
    );
    await repo.createItem(blazer);
    await repo.createItem(shirt);
    final outfit = await repo.createOutfit(
      Outfit(
        id: 'outfit-1',
        name: 'Work',
        itemIds: const ['shirt', 'blazer'],
        occasions: const [WardrobeOccasion.business],
        dressCode: DressCode.businessFormal,
        season: WardrobeSeason.allSeason,
        climateTags: const [],
        isFavorite: false,
        createdAt: DateTime(2026, 8, 11),
        updatedAt: DateTime(2026, 8, 11),
      ),
    );
    await repo.createOutfitPlan(
      OutfitPlan(
        id: 'plan-1',
        outfitId: outfit.id,
        localDate: LocalDate(2026, 8, 12),
        occasion: WardrobeOccasion.business,
        dressCode: DressCode.businessFormal,
        createdAt: DateTime(2026, 8, 11),
        updatedAt: DateTime(2026, 8, 11),
      ),
    );
    await repo.recordWear(
      WearRecord(
        id: 'wear-1',
        localDate: LocalDate(2026, 8, 11),
        outfitId: outfit.id,
        itemIds: outfit.itemIds,
        createdAt: DateTime(2026, 8, 11),
        updatedAt: DateTime(2026, 8, 11),
      ),
    );

    final reopened = LocalWardrobeRepository(prefs: prefs, imageStore: store);
    expect(await reopened.getItems(), hasLength(2));
    expect(await reopened.getOutfits(), hasLength(1));
    expect(
      await reopened.getPlansForDateRange(
        start: LocalDate(2026, 8, 12),
        endInclusive: LocalDate(2026, 8, 12),
      ),
      hasLength(1),
    );

    await reopened.deleteLocalRecords();
    final after = LocalWardrobeRepository(prefs: prefs, imageStore: store);
    expect(await after.getItems(), isEmpty);
    expect(await after.getOutfits(), isEmpty);
  });
}
