import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/trust_providers.dart';
import '../../domain/entities/deletion_scope.dart';
import '../widgets/trust_screen_scaffold.dart';

class PrivacyDeletionScreen extends ConsumerStatefulWidget {
  const PrivacyDeletionScreen({super.key});

  @override
  ConsumerState<PrivacyDeletionScreen> createState() =>
      _PrivacyDeletionScreenState();
}

class _PrivacyDeletionScreenState extends ConsumerState<PrivacyDeletionScreen> {
  final Set<DeletionScope> _selected = {};
  bool _busy = false;
  DeletionResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('privacy_deletion'),
      title: 'Delete local data',
      subtitle: 'MeMy-owned data on this device only',
      fallbackPath: RoutePaths.privacy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'This never deletes events from your device calendars or data '
            'in HealthKit / Health Connect.',
            style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._scopes.map((scope) {
            return CheckboxListTile(
              key: Key('delete_scope_${scope.name}'),
              value: _selected.contains(scope),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    if (scope == DeletionScope.allLocalMeMyData) {
                      _selected
                        ..clear()
                        ..add(DeletionScope.allLocalMeMyData);
                    } else {
                      _selected.remove(DeletionScope.allLocalMeMyData);
                      _selected.add(scope);
                    }
                  } else {
                    _selected.remove(scope);
                  }
                });
              },
              title: Text(_label(scope)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            key: const Key('delete_run'),
            label: _busy ? 'Deleting…' : 'Delete selected',
            onPressed: _busy || _selected.isEmpty ? null : _confirmAndRun,
          ),
          if (_lastResult != null) ...[
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deleted', style: AppTextStyles.titleSmall()),
                  ..._lastResult!.deletedCounts.entries.map(
                    (e) => Text('${e.key}: ${e.value}'),
                  ),
                  if (_lastResult!.warnings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _lastResult!.warnings.join('\n'),
                      style: AppTextStyles.bodySmall(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _scopes = [
    DeletionScope.goals,
    DeletionScope.finance,
    DeletionScope.habits,
    DeletionScope.calendarCache,
    DeletionScope.healthConnectionConfiguration,
    DeletionScope.preferences,
    DeletionScope.allLocalMeMyData,
  ];

  String _label(DeletionScope scope) => switch (scope) {
    DeletionScope.goals => 'Goals',
    DeletionScope.finance => 'Finance transactions',
    DeletionScope.habits => 'Habits',
    DeletionScope.calendarCache => 'Calendar local cache',
    DeletionScope.healthCache => 'Health cache',
    DeletionScope.healthConnectionConfiguration =>
      'Health connection configuration',
    DeletionScope.preferences => 'Appearance preferences',
    DeletionScope.allLocalMeMyData => 'All local MeMy data',
  };

  Future<void> _confirmAndRun() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected data?'),
        content: const Text(
          'This cannot be undone. External calendars and platform Health '
          'stores are not modified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('delete_confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(localDataDeletionCoordinatorProvider)
          .delete(Set<DeletionScope>.from(_selected));
      setState(() => _lastResult = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
