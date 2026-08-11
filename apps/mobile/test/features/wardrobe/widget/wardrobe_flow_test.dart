import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/wardrobe/application/controllers/item_form_controller.dart';
import 'package:memy/features/wardrobe/application/providers/wardrobe_providers.dart';
import 'package:memy/features/wardrobe/domain/entities/wardrobe_enums.dart';
import 'package:memy/features/wardrobe/domain/entities/wardrobe_models.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('wardrobe overview empty, add item, outfits and suggestions', (
    tester,
  ) async {
    await pumpMemyApp(tester, seedFinance: false, seedGoals: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.wardrobe);
    await pumpForNavigation(tester);
    expect(find.byKey(const Key('wardrobe_overview')), findsOneWidget);
    expect(find.byKey(const Key('wardrobe_empty')), findsOneWidget);

    router.go(RoutePaths.addWardrobeItem);
    await pumpForNavigation(tester);
    expect(find.byKey(const Key('wardrobe_item_form')), findsOneWidget);

    await tester.tap(find.byKey(const Key('wardrobe_item_save')));
    await pumpForNavigation(tester);
    expect(find.text('Name is required'), findsOneWidget);

    final context = tester.element(find.byKey(const Key('wardrobe_item_form')));
    final container = ProviderScope.containerOf(context);
    final controller = container.read(
      addWardrobeItemControllerProvider.notifier,
    );
    controller.setName('Navy Blazer');
    controller.setCategory(WardrobeItemCategory.outerwear);
    controller.setOccasions(const [WardrobeOccasion.business]);
    controller.setDressCodes(const [DressCode.businessFormal]);
    final first = await Future.wait([
      controller.submit(),
      controller.submit(),
    ]);
    expect(first.whereType<String>().toSet(), hasLength(1));

    final repo = container.read(wardrobeRepositoryProvider);
    final outfit = await () async {
      await repo.createItem(
        WardrobeItem(
          id: 'shirt',
          name: 'White Shirt',
          category: WardrobeItemCategory.tops,
          status: WardrobeItemStatus.available,
          isFavorite: false,
          colorKeys: const [WardrobeColorKey.white],
          seasons: const [WardrobeSeason.allSeason],
          occasions: const [WardrobeOccasion.business],
          dressCodes: const [DressCode.businessFormal],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repo.createItem(
        WardrobeItem(
          id: 'trousers',
          name: 'Black Trousers',
          category: WardrobeItemCategory.bottoms,
          status: WardrobeItemStatus.available,
          isFavorite: false,
          colorKeys: const [WardrobeColorKey.black],
          seasons: const [WardrobeSeason.allSeason],
          occasions: const [WardrobeOccasion.business],
          dressCodes: const [DressCode.businessFormal],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repo.createItem(
        WardrobeItem(
          id: 'shoes',
          name: 'Black Shoes',
          category: WardrobeItemCategory.footwear,
          status: WardrobeItemStatus.available,
          isFavorite: false,
          colorKeys: const [WardrobeColorKey.black],
          seasons: const [WardrobeSeason.allSeason],
          occasions: const [WardrobeOccasion.business],
          dressCodes: const [DressCode.businessFormal],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final items = await repo.getItems();
      expect(items, hasLength(4));
      final created = await repo.createOutfit(
        Outfit(
          id: 'look',
          name: 'Business look',
          itemIds: items.map((i) => i.id).toList(),
          occasions: const [WardrobeOccasion.business],
          dressCode: DressCode.businessFormal,
          season: WardrobeSeason.allSeason,
          climateTags: const [],
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final suggestions = await repo.getSuggestedOutfits(
        OutfitSuggestionRequest(
          localDate: LocalDate.fromDateTime(DateTime.now()),
          occasion: WardrobeOccasion.business,
          dressCode: DressCode.businessFormal,
        ),
      );
      expect(suggestions, isNotEmpty);

      await repo.createOutfitPlan(
        OutfitPlan(
          id: 'plan-today',
          outfitId: created.id,
          localDate: LocalDate.fromDateTime(DateTime.now()),
          occasion: WardrobeOccasion.business,
          dressCode: DressCode.businessFormal,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return created;
    }();
    expect(outfit, isNotNull);
    container.invalidate(wardrobeItemsProvider);
    container.invalidate(wardrobeOutfitsProvider);
    container.invalidate(wardrobePlansProvider);
    container.invalidate(wardrobeWearProvider);

    router.go(RoutePaths.today);
    await pumpUntilFound(tester, find.byKey(const Key('today_wardrobe_card')));
    expect(find.byKey(const Key('today_wardrobe_card')), findsOneWidget);

    router.go(RoutePaths.wardrobeSuggestions);
    await pumpUntilFound(tester, find.textContaining('created locally'));
    expect(find.textContaining('created locally'), findsWidgets);

    await tester.runAsync(repo.deleteLocalRecords);
    expect(await repo.getItems(), isEmpty);
  });
}
