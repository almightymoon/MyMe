import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_enums.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../widgets/wardrobe_item_thumb.dart';

class WardrobeItemsScreen extends ConsumerStatefulWidget {
  const WardrobeItemsScreen({super.key});

  @override
  ConsumerState<WardrobeItemsScreen> createState() =>
      _WardrobeItemsScreenState();
}

class _WardrobeItemsScreenState extends ConsumerState<WardrobeItemsScreen> {
  String _query = '';
  WardrobeItemCategory? _category;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    return MemyModuleScaffold(
      key: const Key('wardrobe_items'),
      title: 'Items',
      fallbackPath: RoutePaths.wardrobe,
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addWardrobeItem),
      ),
      child: itemsAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeItemsProvider),
        ),
        data: (items) {
          final filtered = items.where((item) {
            if (_category != null && item.category != _category) return false;
            if (_query.trim().isEmpty) return true;
            final q = _query.toLowerCase();
            return item.name.toLowerCase().contains(q) ||
                (item.brand?.toLowerCase().contains(q) ?? false) ||
                (item.material?.toLowerCase().contains(q) ?? false) ||
                (item.notes?.toLowerCase().contains(q) ?? false);
          }).toList();
          return Column(
            children: [
              TextField(
                key: const Key('wardrobe_item_search'),
                decoration: const InputDecoration(labelText: 'Search'),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final category in WardrobeItemCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                const EmptyFeatureCard(
                  key: Key('wardrobe_items_empty'),
                  title: 'No items',
                  message: 'Try another filter or add an item.',
                )
              else
                for (final item in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ItemRow(item: item),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: Key('wardrobe_item_tile_${item.id}'),
      onTap: () => context.push(RoutePaths.wardrobeItemPath(item.id)),
      child: Row(
        children: [
          WardrobeItemThumb(item: item, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name),
                Text('${item.category.label} · ${item.status.label}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
