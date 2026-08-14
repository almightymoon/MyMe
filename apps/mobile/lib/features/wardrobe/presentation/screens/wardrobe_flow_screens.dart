import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/release_capabilities.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_enums.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../widgets/wardrobe_item_thumb.dart';

class WardrobeItemDetailScreen extends ConsumerWidget {
  const WardrobeItemDetailScreen({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemByIdProvider(itemId));
    final wearAsync = ref.watch(wardrobeWearProvider);
    final outfits = ref.watch(wardrobeOutfitsProvider).valueOrNull ?? const [];
    return MemyModuleScaffold(
      key: const Key('wardrobe_item_detail'),
      title: 'Item',
      fallbackPath: RoutePaths.wardrobeItems,
      showBottomNav: false,
      child: itemAsync.when(
        loading: () => const LoadingCardSkeleton(height: 160, lines: 4),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeItemsProvider),
        ),
        data: (item) {
          if (item == null) {
            return const EmptyFeatureCard(
              title: 'Item not found',
              message: 'This item is no longer on this device.',
            );
          }
          final wearCount = (wearAsync.valueOrNull ?? const [])
              .where((w) => w.itemIds.contains(item.id))
              .length;
          final usedIn = outfits
              .where((o) => o.itemIds.contains(item.id))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WardrobeItemThumb(item: item, size: 180, full: true),
              const SizedBox(height: 12),
              Text(item.name),
              Text('${item.category.label} · ${item.status.label}'),
              Text('Worn $wearCount times'),
              if (usedIn.isNotEmpty) Text('In ${usedIn.length} outfit(s)'),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () =>
                        context.push(RoutePaths.editWardrobeItemPath(item.id)),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(wardrobeRepositoryProvider)
                          .setFavorite(item.id, !item.isFavorite);
                      invalidateWardrobe(ref);
                    },
                    child: Text(item.isFavorite ? 'Unfavorite' : 'Favorite'),
                  ),
                  TextButton(
                    onPressed: () => _delete(context, ref, item, usedIn.length),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WardrobeItem item,
    int outfitCount,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this item?'),
        content: Text(
          outfitCount == 0
              ? 'The photo file will be deleted from this device.'
              : 'This item is in $outfitCount outfit(s). Deleting removes it from active outfits. Wear history keeps a date-only record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'archive'),
            child: const Text('Archive instead'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted || choice == null || choice == 'cancel') return;
    try {
      if (choice == 'archive') {
        await ref.read(wardrobeRepositoryProvider).archiveItem(item.id);
      } else {
        await ref.read(wardrobeRepositoryProvider).deleteItem(item.id);
      }
      invalidateWardrobe(ref);
      if (!context.mounted) return;
      context.go(RoutePaths.wardrobeItems);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }
}

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsync = ref.watch(wardrobeOutfitsProvider);
    final items = <String, WardrobeItem>{
      for (final item
          in ref.watch(wardrobeItemsProvider).valueOrNull ??
              const <WardrobeItem>[])
        item.id: item,
    };
    return MemyModuleScaffold(
      key: const Key('wardrobe_outfits'),
      title: 'Outfits',
      fallbackPath: RoutePaths.wardrobe,
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addOutfit),
      ),
      child: outfitsAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeOutfitsProvider),
        ),
        data: (outfits) {
          if (outfits.isEmpty) {
            return EmptyFeatureCard(
              key: const Key('outfits_empty'),
              title: 'No outfits yet',
              message: 'Build an outfit from items on this device.',
              actionLabel: 'Create outfit',
              onAction: () => context.push(RoutePaths.addOutfit),
            );
          }
          return Column(
            children: [
              for (final outfit in outfits)
                ListTile(
                  title: Text(outfit.name),
                  subtitle: Text(
                    outfit.isArchived
                        ? 'Archived'
                        : '${outfit.itemIds.length} items · ${outfit.dressCode.label}',
                  ),
                  onTap: () =>
                      context.push(RoutePaths.outfitDetailPath(outfit.id)),
                  leading: outfit.itemIds.isEmpty
                      ? const Icon(Icons.checkroom_outlined)
                      : WardrobeItemThumb(
                          item:
                              items[outfit.itemIds.first] ??
                              WardrobeItem(
                                id: 'missing',
                                name: 'Missing item',
                                category: WardrobeItemCategory.other,
                                status: WardrobeItemStatus.unavailable,
                                isFavorite: false,
                                colorKeys: const [],
                                seasons: const [],
                                occasions: const [],
                                dressCodes: const [],
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                          size: 40,
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class OutfitFormScreen extends ConsumerStatefulWidget {
  const OutfitFormScreen({super.key, this.outfitId});
  final String? outfitId;

  @override
  ConsumerState<OutfitFormScreen> createState() => _OutfitFormScreenState();
}

class _OutfitFormScreenState extends ConsumerState<OutfitFormScreen> {
  final _name = TextEditingController(text: 'Outfit');
  final _selected = <String>{};
  DressCode _dressCode = DressCode.casual;
  WardrobeOccasion _occasion = WardrobeOccasion.casual;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = (ref.watch(wardrobeItemsProvider).valueOrNull ?? const [])
        .where((i) => !i.isArchived)
        .toList();
    if (widget.outfitId != null) {
      final existing = ref
          .watch(wardrobeOutfitByIdProvider(widget.outfitId!))
          .valueOrNull;
      if (existing != null && _selected.isEmpty) {
        _name.text = existing.name;
        _selected.addAll(existing.itemIds);
        _dressCode = existing.dressCode;
        if (existing.occasions.isNotEmpty) _occasion = existing.occasions.first;
      }
    }
    return MemyModuleScaffold(
      key: const Key('outfit_form'),
      title: widget.outfitId == null ? 'Create outfit' : 'Edit outfit',
      fallbackPath: RoutePaths.wardrobeOutfits,
      showBottomNav: false,
      child: Column(
        children: [
          if (_error != null) Text(_error!),
          TextField(
            key: const Key('outfit_name_field'),
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          DropdownButtonFormField<DressCode>(
            // ignore: deprecated_member_use
            value: _dressCode,
            items: [
              for (final value in DressCode.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _dressCode = value);
            },
          ),
          const SizedBox(height: 8),
          for (final item in items)
            CheckboxListTile(
              value: _selected.contains(item.id),
              title: Text(item.name),
              subtitle: Text(
                '${item.category.label}${item.status.canBeWorn ? '' : ' · ${item.status.label}'}',
              ),
              onChanged: !item.status.canBeWorn
                  ? null
                  : (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(item.id);
                        } else {
                          _selected.remove(item.id);
                        }
                      });
                    },
            ),
          MemyPrimaryButton(
            key: const Key('outfit_save'),
            label: _busy ? 'Saving…' : 'Save outfit',
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      final repo = ref.read(wardrobeRepositoryProvider);
                      final now = DateTime.now();
                      final outfit = Outfit(
                        id: widget.outfitId ?? ref.read(uuidProvider).v4(),
                        name: _name.text.trim().isEmpty
                            ? 'Outfit'
                            : _name.text.trim(),
                        itemIds: _selected.toList(),
                        occasions: [_occasion],
                        dressCode: _dressCode,
                        season: WardrobeSeason.allSeason,
                        climateTags: const [],
                        isFavorite: false,
                        createdAt: now,
                        updatedAt: now,
                      );
                      if (widget.outfitId == null) {
                        await repo.createOutfit(outfit);
                      } else {
                        await repo.updateOutfit(outfit);
                      }
                      invalidateWardrobe(ref);
                      if (!context.mounted) return;
                      context.go(RoutePaths.outfitDetailPath(outfit.id));
                    } catch (error) {
                      setState(() {
                        _busy = false;
                        _error = userFacingErrorMessage(error);
                      });
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class OutfitDetailScreen extends ConsumerWidget {
  const OutfitDetailScreen({super.key, required this.outfitId});
  final String outfitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitAsync = ref.watch(wardrobeOutfitByIdProvider(outfitId));
    final items = {
      for (final item in ref.watch(wardrobeItemsProvider).valueOrNull ?? [])
        item.id: item,
    };
    return MemyModuleScaffold(
      key: const Key('outfit_detail'),
      title: 'Outfit',
      fallbackPath: RoutePaths.wardrobeOutfits,
      showBottomNav: false,
      child: outfitAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeOutfitsProvider),
        ),
        data: (outfit) {
          if (outfit == null) {
            return const EmptyFeatureCard(
              title: 'Outfit not found',
              message: 'This outfit is no longer on this device.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(outfit.name),
              Text(outfit.dressCode.label),
              for (final id in outfit.itemIds)
                if (items[id] != null)
                  ListTile(
                    leading: WardrobeItemThumb(item: items[id]!, size: 40),
                    title: Text(items[id]!.name),
                    subtitle: Text(items[id]!.status.label),
                  )
                else
                  const ListTile(title: Text('Missing item')),
              TextButton(
                onPressed: () =>
                    context.push(RoutePaths.editOutfitPath(outfit.id)),
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () => context.push(
                  '${RoutePaths.wardrobePlanner}?outfitId=${outfit.id}',
                ),
                child: const Text('Plan for date'),
              ),
              TextButton(
                onPressed: () async {
                  final repo = ref.read(wardrobeRepositoryProvider);
                  final now = DateTime.now();
                  await repo.recordWear(
                    WearRecord(
                      id: ref.read(uuidProvider).v4(),
                      localDate: LocalDate.fromDateTime(now),
                      outfitId: outfit.id,
                      itemIds: outfit.itemIds,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
                  invalidateWardrobe(ref);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as worn today')),
                  );
                },
                child: const Text('Record worn today'),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(wardrobeRepositoryProvider)
                      .deleteOutfit(outfit.id);
                  if (!context.mounted) return;
                  context.go(RoutePaths.wardrobeOutfits);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OutfitSuggestionsScreen extends ConsumerStatefulWidget {
  const OutfitSuggestionsScreen({super.key});

  @override
  ConsumerState<OutfitSuggestionsScreen> createState() =>
      _OutfitSuggestionsScreenState();
}

class _OutfitSuggestionsScreenState
    extends ConsumerState<OutfitSuggestionsScreen> {
  DressCode _dressCode = DressCode.businessFormal;
  WardrobeOccasion _occasion = WardrobeOccasion.business;
  List<OutfitSuggestion> _results = const [];
  List<String> _missing = const [];
  var _ran = false;

  @override
  Widget build(BuildContext context) {
    return MemyModuleScaffold(
      key: const Key('wardrobe_suggestions'),
      title: 'Suggestions',
      fallbackPath: RoutePaths.wardrobe,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Suggestions are created locally from your available wardrobe items.',
          ),
          DropdownButtonFormField<DressCode>(
            // ignore: deprecated_member_use
            value: _dressCode,
            items: [
              for (final value in DressCode.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _dressCode = value);
            },
          ),
          DropdownButtonFormField<WardrobeOccasion>(
            // ignore: deprecated_member_use
            value: _occasion,
            items: [
              for (final value in WardrobeOccasion.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _occasion = value);
            },
          ),
          MemyPrimaryButton(
            key: const Key('wardrobe_run_suggestions'),
            label: 'Suggest outfits',
            onPressed: () async {
              final repo = ref.read(wardrobeRepositoryProvider);
              final items = await repo.getItems();
              final prefs = ref.read(wardrobeUserPreferencesProvider);
              final results = await repo.getSuggestedOutfits(
                OutfitSuggestionRequest(
                  localDate: LocalDate.fromDateTime(
                    ref.read(appClockProvider).now(),
                  ),
                  occasion: _occasion,
                  dressCode: _dressCode,
                  climateTags: [
                    if (prefs.defaultClimateTag != null)
                      prefs.defaultClimateTag!,
                  ],
                  avoidRecentlyWornDays: prefs.avoidRecentlyWornDays,
                ),
              );
              final missing = ref
                  .read(wardrobeSuggestionServiceProvider)
                  .missingCategories(items: items, dressCode: _dressCode);
              setState(() {
                _results = results;
                _missing = missing;
                _ran = true;
              });
            },
          ),
          if (_ran && _results.isEmpty)
            EmptyFeatureCard(
              key: const Key('suggestions_empty'),
              title: 'No suggestion yet',
              message: _missing.isEmpty
                  ? 'Add more available items and try again.'
                  : 'Missing: ${_missing.join(', ')}.',
              actionLabel: 'Add item',
              onAction: () => context.push(RoutePaths.addWardrobeItem),
            ),
          for (final suggestion in _results)
            ListTile(
              title: Text('Suggestion (${suggestion.score})'),
              subtitle: Text(suggestion.reasons.take(2).join(' ')),
              onTap: () async {
                final repo = ref.read(wardrobeRepositoryProvider);
                final now = DateTime.now();
                final outfit = await repo.createOutfit(
                  Outfit(
                    id: ref.read(uuidProvider).v4(),
                    name: 'Suggested outfit',
                    itemIds: suggestion.itemIds,
                    occasions: [_occasion],
                    dressCode: _dressCode,
                    season: WardrobeSeason.allSeason,
                    climateTags: const [],
                    isFavorite: false,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
                invalidateWardrobe(ref);
                if (!context.mounted) return;
                context.push(RoutePaths.outfitDetailPath(outfit.id));
              },
            ),
        ],
      ),
    );
  }
}

class OutfitPlannerScreen extends ConsumerStatefulWidget {
  const OutfitPlannerScreen({super.key, this.outfitId, this.eventId});
  final String? outfitId;
  final String? eventId;

  @override
  ConsumerState<OutfitPlannerScreen> createState() =>
      _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends ConsumerState<OutfitPlannerScreen> {
  LocalDate _date = LocalDate.fromDateTime(
    DateTime.now().add(const Duration(days: 1)),
  );
  String? _outfitId;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _outfitId = widget.outfitId;
  }

  @override
  Widget build(BuildContext context) {
    final outfits = (ref.watch(wardrobeOutfitsProvider).valueOrNull ?? const [])
        .where((o) => !o.isArchived)
        .toList();
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    return MemyModuleScaffold(
      key: const Key('wardrobe_planner'),
      title: 'Plan outfit',
      fallbackPath: RoutePaths.wardrobe,
      child: Column(
        children: [
          ListTile(
            title: Text(_date.toIso8601String()),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date.toDateTimeLocal(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked == null) return;
              setState(() => _date = LocalDate.fromDateTime(picked));
            },
          ),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: outfits.any((o) => o.id == _outfitId) ? _outfitId : null,
            decoration: const InputDecoration(labelText: 'Outfit'),
            items: [
              for (final outfit in outfits)
                DropdownMenuItem(value: outfit.id, child: Text(outfit.name)),
            ],
            onChanged: (value) => setState(() => _outfitId = value),
          ),
          MemyPrimaryButton(
            key: const Key('planner_save'),
            label: _busy ? 'Saving…' : 'Save plan',
            onPressed: _busy || _outfitId == null
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      await ref
                          .read(wardrobeRepositoryProvider)
                          .createOutfitPlan(
                            OutfitPlan(
                              id: ref.read(uuidProvider).v4(),
                              outfitId: _outfitId!,
                              localDate: _date,
                              calendarEventId: widget.eventId,
                              calendarEventSource: widget.eventId == null
                                  ? null
                                  : 'device',
                              occasion: WardrobeOccasion.business,
                              dressCode: DressCode.businessFormal,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                            replace: true,
                          );
                      invalidateWardrobe(ref);
                      if (!context.mounted) return;
                      context.go(RoutePaths.wardrobe);
                    } catch (error) {
                      if (!context.mounted) return;
                      setState(() => _busy = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(userFacingErrorMessage(error))),
                      );
                    }
                  },
          ),
          if (capabilities.deviceCalendar)
            const Text(
              'Calendar events stay read-only. MeMy stores only a local reference.',
            ),
        ],
      ),
    );
  }
}

class WardrobeHistoryScreen extends ConsumerWidget {
  const WardrobeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wearAsync = ref.watch(wardrobeWearProvider);
    return MemyModuleScaffold(
      key: const Key('wardrobe_history'),
      title: 'Wear history',
      fallbackPath: RoutePaths.wardrobe,
      child: wearAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeWearProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyFeatureCard(
              key: Key('wardrobe_history_empty'),
              title: 'No wear records',
              message: 'Mark an outfit as worn to start history.',
            );
          }
          final sorted = [...records]
            ..sort((a, b) => b.localDate.compareTo(a.localDate));
          return Column(
            children: [
              for (final record in sorted)
                ListTile(
                  title: Text(record.localDate.toIso8601String()),
                  subtitle: Text('${record.itemIds.length} items'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(wardrobeRepositoryProvider)
                          .deleteWearRecord(record.id);
                      invalidateWardrobe(ref);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
