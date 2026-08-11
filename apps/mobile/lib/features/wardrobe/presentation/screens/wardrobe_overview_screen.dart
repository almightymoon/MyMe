import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_enums.dart';

class WardrobeOverviewScreen extends ConsumerWidget {
  const WardrobeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    final outfitsAsync = ref.watch(wardrobeOutfitsProvider);
    final planAsync = ref.watch(todayOutfitPlanProvider);

    return MemyModuleScaffold(
      key: const Key('wardrobe_overview'),
      title: 'Wardrobe',
      heroAsset: 'assets/images/modules/mod-wardrobe.png',
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addWardrobeItem),
      ),
      child: itemsAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          key: const Key('wardrobe_error'),
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeItemsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyFeatureCard(
              key: const Key('wardrobe_empty'),
              title: 'Wardrobe',
              message:
                  'Add clothing photos stored only on this device. Nothing is uploaded.',
              icon: Icons.checkroom_outlined,
              actionLabel: 'Add first item',
              onAction: () => context.push(RoutePaths.addWardrobeItem),
            );
          }
          final available = items
              .where((i) => i.status == WardrobeItemStatus.available)
              .length;
          final laundry = items
              .where(
                (i) =>
                    i.status == WardrobeItemStatus.inLaundry ||
                    i.status == WardrobeItemStatus.needsCleaning,
              )
              .length;
          final favorites = items.where((i) => i.isFavorite).length;
          final outfits = outfitsAsync.valueOrNull ?? const [];
          final plan = planAsync.valueOrNull;
          return Column(
            key: const Key('wardrobe_populated'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${items.length} items · $available available · $laundry in laundry · $favorites favorites',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: AppSpacing.md),
              if (plan != null)
                Text('Today’s planned outfit is ready in Outfits.'),
              _Nav('Items', RoutePaths.wardrobeItems, 'wardrobe_nav_items'),
              _Nav(
                'Outfits',
                RoutePaths.wardrobeOutfits,
                'wardrobe_nav_outfits',
              ),
              _Nav(
                'Suggestions',
                RoutePaths.wardrobeSuggestions,
                'wardrobe_nav_suggestions',
              ),
              _Nav(
                'Planner',
                RoutePaths.wardrobePlanner,
                'wardrobe_nav_planner',
              ),
              _Nav(
                'Wear history',
                RoutePaths.wardrobeHistory,
                'wardrobe_nav_history',
              ),
              Text(
                '${outfits.length} saved outfits. Suggestions are created locally from your available wardrobe items.',
                style: AppTextStyles.bodySmall(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.label, this.path, this.keyName);
  final String label;
  final String path;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: Key(keyName),
        onTap: () => context.push(path),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
