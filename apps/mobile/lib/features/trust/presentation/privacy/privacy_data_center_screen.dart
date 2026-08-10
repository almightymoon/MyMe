import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../application/providers/trust_providers.dart';
import '../../domain/entities/data_catalog.dart';
import '../widgets/trust_screen_scaffold.dart';

class PrivacyDataCenterScreen extends ConsumerWidget {
  const PrivacyDataCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(dataCatalogEntriesProvider);

    return TrustScreenScaffold(
      key: const Key('privacy_data_center'),
      title: 'Privacy & Data',
      subtitle: 'What MeMy stores and where it stays',
      fallbackPath: RoutePaths.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'This catalog matches current app behavior. It is not a GDPR, '
            'HIPAA, or encryption certification.',
            style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          ...entries.map((e) => _CatalogTile(entry: e)),
          const SizedBox(height: AppSpacing.lg),
          Text('Actions', style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.sm),
          _LinkCard(
            keyName: 'privacy_export',
            icon: Icons.download_outlined,
            title: 'Export local data',
            subtitle: 'JSON export of selected MeMy modules',
            onTap: () => context.push(RoutePaths.privacyExport),
          ),
          _LinkCard(
            keyName: 'privacy_deletion',
            icon: Icons.delete_outline_rounded,
            title: 'Delete local data',
            subtitle: 'Wipe MeMy-owned data on this device',
            onTap: () => context.push(RoutePaths.privacyDeletion),
          ),
          _LinkCard(
            keyName: 'privacy_ai_use',
            icon: Icons.psychology_outlined,
            title: 'AI data use',
            subtitle: 'What AI Coach does and does not receive',
            onTap: () => context.push(RoutePaths.privacyAiDataUse),
          ),
          _LinkCard(
            keyName: 'privacy_permissions',
            icon: Icons.shield_outlined,
            title: 'Permissions & connections',
            subtitle: 'Calendar, Health, and Connected Apps',
            onTap: () => context.push(RoutePaths.connectedApps),
          ),
        ],
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.entry});

  final DataCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: AppTextStyles.titleMedium()),
            const SizedBox(height: 4),
            Text(
              entry.summary,
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Chip(
                  label: entry.backendTransfer ? 'Backend: yes' : 'Backend: no',
                ),
                _Chip(label: entry.aiTransfer ? 'AI: yes' : 'AI: no'),
                _Chip(label: entry.sensitivity.name),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall().copyWith(fontSize: 11),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.keyName,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        key: Key(keyName),
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ember),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall()),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}
