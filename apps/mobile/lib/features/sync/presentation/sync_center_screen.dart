import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../../auth/application/auth_session_controller.dart';
import '../application/sync_status_controller.dart';
import '../domain/sync_models.dart';

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final session = ref.watch(authSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.label, style: AppTextStyles.titleMedium()),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Account: ${session == null ? 'Signed out' : 'Signed in'}\n'
                  'Pending changes: ${status.pendingCount}\n'
                  'Conflicts: ${status.conflictCount}',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            label: 'Sync now',
            onPressed: () {
              ref.read(syncStatusProvider.notifier).state = SyncStatusSnapshot(
                kind: SyncStatusKind.syncing,
                pendingCount: status.pendingCount,
                conflictCount: status.conflictCount,
                lastSuccessfulSyncAt: status.lastSuccessfulSyncAt,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(RoutePaths.conflictCenter),
            child: const Text('Review conflicts'),
          ),
          TextButton(
            onPressed: () => context.push(RoutePaths.deviceSessions),
            child: const Text('Device sessions'),
          ),
        ],
      ),
    );
  }
}
