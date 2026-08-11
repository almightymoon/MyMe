import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../auth/application/auth_session_controller.dart';
import '../../../auth/data/account_local_store.dart';
import '../../../auth/data/account_namespace.dart';
import '../../data/repositories/local_wardrobe_repository.dart';
import '../../data/storage/local_wardrobe_image_store.dart';
import '../../domain/entities/wardrobe_enums.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../domain/services/outfit_suggestion_service.dart';
import '../../domain/services/wardrobe_image_store.dart';

final wardrobeDocumentsDirectoryProvider =
    Provider<Future<Directory> Function()?>((ref) => null);

final wardrobeImageStoreProvider = Provider<WardrobeImageStore>((ref) {
  final accountId = ref.watch(authSessionProvider)?.userId;
  return LocalWardrobeImageStore(
    documentsDirectory: () async {
      final override = ref.read(wardrobeDocumentsDirectoryProvider);
      if (override != null) return override();
      try {
        return await getApplicationDocumentsDirectory();
      } on Object {
        return Directory.systemTemp;
      }
    },
    idGenerator: () => ref.read(uuidProvider).v4(),
    accountNamespace: accountId == null
        ? 'legacy'
        : accountStorageNamespace(accountId),
  );
});

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  final store = AccountLocalStore(ref.watch(authSessionProvider)?.userId);
  final repo = LocalWardrobeRepository(
    prefs: ref.watch(sharedPreferencesProvider),
    documentKey: store.key(LocalWardrobeRepository.storageKey),
    initKey: store.key(LocalWardrobeRepository.initializedKey),
    imageStore: ref.watch(wardrobeImageStoreProvider),
    clock: ref.watch(appClockProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

final wardrobeItemsProvider = FutureProvider.autoDispose<List<WardrobeItem>>((
  ref,
) {
  return ref.watch(wardrobeRepositoryProvider).getItems();
});

final wardrobeOutfitsProvider = FutureProvider.autoDispose<List<Outfit>>((ref) {
  return ref.watch(wardrobeRepositoryProvider).getOutfits();
});

final wardrobePlansProvider = FutureProvider.autoDispose<List<OutfitPlan>>((
  ref,
) async {
  final today = LocalDate.fromDateTime(ref.watch(appClockProvider).now());
  return ref
      .watch(wardrobeRepositoryProvider)
      .getPlansForDateRange(
        start: LocalDate(today.year - 1, 1, 1),
        endInclusive: LocalDate(today.year + 2, 12, 31),
      );
});

final wardrobeWearProvider = FutureProvider.autoDispose<List<WearRecord>>((
  ref,
) {
  return ref.watch(wardrobeRepositoryProvider).getWearRecords();
});

void invalidateWardrobe(WidgetRef ref) {
  ref.invalidate(wardrobeItemsProvider);
  ref.invalidate(wardrobeOutfitsProvider);
  ref.invalidate(wardrobePlansProvider);
  ref.invalidate(wardrobeWearProvider);
}

final wardrobeItemByIdProvider = Provider.autoDispose
    .family<AsyncValue<WardrobeItem?>, String>((ref, id) {
      return ref.watch(wardrobeItemsProvider).whenData((items) {
        for (final item in items) {
          if (item.id == id) return item;
        }
        return null;
      });
    });

final wardrobeOutfitByIdProvider = Provider.autoDispose
    .family<AsyncValue<Outfit?>, String>((ref, id) {
      return ref.watch(wardrobeOutfitsProvider).whenData((outfits) {
        for (final outfit in outfits) {
          if (outfit.id == id) return outfit;
        }
        return null;
      });
    });

final todayOutfitPlanProvider = Provider.autoDispose<AsyncValue<OutfitPlan?>>((
  ref,
) {
  final today = LocalDate.fromDateTime(ref.watch(appClockProvider).now());
  return ref.watch(wardrobePlansProvider).whenData((plans) {
    for (final plan in plans) {
      if (plan.localDate == today) return plan;
    }
    return null;
  });
});

final upcomingOutfitPlansProvider =
    Provider.autoDispose<AsyncValue<List<OutfitPlan>>>((ref) {
      final today = LocalDate.fromDateTime(ref.watch(appClockProvider).now());
      return ref.watch(wardrobePlansProvider).whenData((plans) {
        final upcoming =
            plans.where((p) => p.localDate.isSameOrAfter(today)).toList()
              ..sort((a, b) => a.localDate.compareTo(b.localDate));
        return upcoming.take(5).toList(growable: false);
      });
    });

final wardrobeSuggestionServiceProvider = Provider<OutfitSuggestionService>((
  ref,
) {
  return const OutfitSuggestionService();
});

class WardrobeUserPreferences {
  const WardrobeUserPreferences({
    this.avoidRecentlyWornDays = 7,
    this.showPurchaseInformation = false,
    this.defaultDressCode,
    this.defaultClimateTag,
  });

  final int avoidRecentlyWornDays;
  final bool showPurchaseInformation;
  final DressCode? defaultDressCode;
  final ClimateTag? defaultClimateTag;
}

final wardrobeUserPreferencesProvider = Provider<WardrobeUserPreferences>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WardrobeUserPreferences(
    avoidRecentlyWornDays: prefs.getInt('memy_wardrobe_avoid_recent_days') ?? 7,
    showPurchaseInformation:
        prefs.getBool('memy_wardrobe_show_purchase') ?? false,
    defaultDressCode: DressCode.tryParse(
      prefs.getString('memy_wardrobe_default_dress_code'),
    ),
    defaultClimateTag: ClimateTag.tryParse(
      prefs.getString('memy_wardrobe_default_climate'),
    ),
  );
});
