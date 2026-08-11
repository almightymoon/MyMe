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
import '../../domain/services/local_data_deletion_coordinator.dart';
import '../widgets/trust_screen_scaffold.dart';

class PrivacyDeletionScreen extends ConsumerStatefulWidget {
  const PrivacyDeletionScreen({super.key});

  @override
  ConsumerState<PrivacyDeletionScreen> createState() =>
      _PrivacyDeletionScreenState();
}

class _PrivacyDeletionScreenState extends ConsumerState<PrivacyDeletionScreen> {
  final Set<DeletionScope> _selected = {};
  final TextEditingController _phraseController = TextEditingController();
  bool _busy = false;
  DeletionPlan? _plan;
  DeletionExecutionReport? _lastReport;

  bool get _isGlobalWipe => _selected.contains(DeletionScope.allLocalMeMyData);

  bool get _phraseMatches =>
      LocalDataDeletionCoordinator.matchesGlobalConfirmation(
        _phraseController.text,
      );

  bool get _canRun {
    if (_busy || _selected.isEmpty) return false;
    if (_isGlobalWipe && !_phraseMatches) return false;
    return true;
  }

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

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
                      _phraseController.clear();
                    } else {
                      _selected.remove(DeletionScope.allLocalMeMyData);
                      _selected.add(scope);
                    }
                  } else {
                    _selected.remove(scope);
                  }
                  _plan = null;
                  _lastReport = null;
                });
                _refreshPlan();
              },
              title: Text(_label(scope)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          }),
          if (_plan != null) ...[
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan preview', style: AppTextStyles.titleSmall()),
                  const SizedBox(height: 8),
                  Text(
                    'Will delete:\n${_plan!.whatWillBeDeleted.map((e) => '• $e').join('\n')}',
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Will remain:\n${_plan!.whatWillRemain.map((e) => '• $e').join('\n')}',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isGlobalWipe) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Type DELETE LOCAL DATA to confirm wiping all local MeMy data.',
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('delete_confirmation_phrase'),
              controller: _phraseController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Confirmation phrase',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            key: const Key('delete_run'),
            label: _busy ? 'Deleting…' : 'Delete selected',
            onPressed: _canRun ? _confirmAndRun : null,
          ),
          if (_lastReport != null) ...[
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lastReport!.overallStatusLabel,
                    style: AppTextStyles.titleSmall(),
                  ),
                  ..._lastReport!.stepResults.map((step) {
                    final count = step.deletedCount;
                    final suffix = count == null ? '' : ' ($count)';
                    return Text(
                      '${step.scope.name}: ${step.status.name}$suffix'
                      '${step.userSafeMessage == null ? '' : ' — ${step.userSafeMessage}'}',
                    );
                  }),
                  if (_lastReport!.warnings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _lastReport!.warnings.join('\n'),
                      style: AppTextStyles.bodySmall(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                  if (_lastReport!.retryableFailedScopes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      key: const Key('delete_retry_failed'),
                      onPressed: _busy ? null : _retryFailed,
                      child: const Text('Retry failed steps'),
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
    DeletionScope.wardrobe,
    DeletionScope.habits,
    DeletionScope.calendarImportedCache,
    DeletionScope.calendarMeMyLocalRecords,
    DeletionScope.calendarIntegrationState,
    DeletionScope.healthDerivedCache,
    DeletionScope.healthConnectionConfiguration,
    DeletionScope.preferences,
    DeletionScope.allLocalMeMyData,
  ];

  String _label(DeletionScope scope) => switch (scope) {
    DeletionScope.goals => 'Goals',
    DeletionScope.goalsLocalCache => 'Goals local cache',
    DeletionScope.finance => 'Finance transactions, budgets, and money owed',
    DeletionScope.wardrobe => 'Wardrobe and local photos',
    DeletionScope.habits => 'Habits',
    DeletionScope.calendarCache => 'Calendar local cache',
    DeletionScope.calendarImportedCache => 'Calendar imported cache',
    DeletionScope.calendarMeMyLocalRecords => 'Calendar MeMy local records',
    DeletionScope.calendarIntegrationState => 'Calendar integration state',
    DeletionScope.calendarDeviceEvents => 'Device calendar events',
    DeletionScope.healthCache => 'Health cache',
    DeletionScope.healthDerivedCache => 'Health derived cache',
    DeletionScope.healthConnectionConfiguration =>
      'Health connection configuration',
    DeletionScope.preferences => 'Appearance preferences',
    DeletionScope.allLocalMeMyData => 'All local MeMy data',
  };

  Future<void> _refreshPlan() async {
    if (_selected.isEmpty) {
      setState(() => _plan = null);
      return;
    }
    final plan = await ref
        .read(localDataDeletionCoordinatorProvider)
        .plan(Set<DeletionScope>.from(_selected));
    if (!mounted) return;
    setState(() => _plan = plan);
  }

  Future<void> _confirmAndRun() async {
    if (_isGlobalWipe && !_phraseMatches) return;

    if (!_isGlobalWipe) {
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
    }

    setState(() => _busy = true);
    try {
      final coordinator = ref.read(localDataDeletionCoordinatorProvider);
      final plan =
          _plan ?? await coordinator.plan(Set<DeletionScope>.from(_selected));
      final report = await coordinator.execute(
        plan,
        confirmationPhrase: _isGlobalWipe
            ? _phraseController.text.trim()
            : null,
      );
      setState(() => _lastReport = report);
    } on DeletionConfirmationException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type DELETE LOCAL DATA exactly to confirm.'),
        ),
      );
    } on DeletionInFlightException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A deletion is already in progress.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retryFailed() async {
    final previous = _lastReport;
    if (previous == null || previous.retryableFailedScopes.isEmpty) return;
    setState(() => _busy = true);
    try {
      final report = await ref
          .read(localDataDeletionCoordinatorProvider)
          .retryFailed(
            previous,
            confirmationPhrase: _isGlobalWipe
                ? _phraseController.text.trim()
                : null,
          );
      if (!mounted) return;
      setState(() => _lastReport = report);
    } on DeletionConfirmationException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type DELETE LOCAL DATA exactly to confirm.'),
        ),
      );
    } on DeletionInFlightException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A deletion is already in progress.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retry failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
