import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../application/providers/trust_providers.dart';
import '../widgets/trust_screen_scaffold.dart';

class AboutMemyScreen extends ConsumerWidget {
  const AboutMemyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionLabelProvider);

    return TrustScreenScaffold(
      key: const Key('about_memy'),
      title: 'About MeMy',
      subtitle: 'Personal life OS by MoonTech',
      fallbackPath: RoutePaths.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MeMy', style: AppTextStyles.titleLarge()),
                const SizedBox(height: 4),
                Text(
                  'A personal life OS for goals, finance, habits, calendar, '
                  'and optional wellness summaries.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  version.when(
                    data: (v) => v,
                    loading: () => 'Version…',
                    error: (_, _) => 'Version unavailable',
                  ),
                  style: AppTextStyles.titleSmall(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyCard(
            key: const Key('about_whats_new'),
            onTap: () => context.push(RoutePaths.whatsNew),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.new_releases_outlined, color: AppColors.ember),
                const SizedBox(width: 12),
                Expanded(
                  child: Text("What's new", style: AppTextStyles.titleSmall()),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.navInactive),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MemyCard(
            onTap: () => context.push(RoutePaths.legal),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.gavel_outlined, color: AppColors.ember),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Legal drafts',
                    style: AppTextStyles.titleSmall(),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.navInactive),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsNewScreen extends ConsumerWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelog = ref.watch(changelogProvider);
    return TrustScreenScaffold(
      key: const Key('whats_new'),
      title: "What's new",
      fallbackPath: RoutePaths.about,
      child: changelog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Could not load changelog: $e'),
        data: (entries) {
          if (entries.isEmpty) {
            return const Text('No changelog entries yet.');
          }
          return Column(
            children: [
              for (final entry in entries) ...[
                MemyCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.version} · ${entry.date.toIso8601String().split('T').first}',
                        style: AppTextStyles.titleSmall(),
                      ),
                      const SizedBox(height: 8),
                      for (final bullet in entry.bullets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $bullet'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        },
      ),
    );
  }
}
