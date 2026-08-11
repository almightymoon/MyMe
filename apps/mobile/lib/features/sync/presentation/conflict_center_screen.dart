import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../application/sync_status_controller.dart';

class ConflictCenterScreen extends ConsumerWidget {
  const ConflictCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Conflicts')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          MemyCard(
            child: Text(
              status.conflictCount == 0
                  ? 'No conflicts need review.'
                  : '${status.conflictCount} change${status.conflictCount == 1 ? '' : 's'} need a choice. MeMy will not discard either version silently.',
              style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
