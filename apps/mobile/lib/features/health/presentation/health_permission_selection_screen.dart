import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/integrations/domain/integration_connection_status.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../application/providers/health_providers.dart';
import '../domain/entities/health_connection_config.dart';
import '../domain/entities/health_metric_type.dart';
import '../domain/entities/health_permission_state.dart';
import 'widgets/health_disclaimer_banner.dart';

/// Per-group permission picker — the only place MeMy ever calls
/// `requestPermissions`, and only after the user taps "Grant access".
///
/// Also doubles as the "Manage access" screen for an already-connected user:
/// shows current grants and offers Disconnect.
class HealthPermissionSelectionScreen extends ConsumerStatefulWidget {
  const HealthPermissionSelectionScreen({super.key});

  @override
  ConsumerState<HealthPermissionSelectionScreen> createState() =>
      _HealthPermissionSelectionScreenState();
}

class _HealthPermissionSelectionScreenState
    extends ConsumerState<HealthPermissionSelectionScreen> {
  /// Default categories offered on first connect — Weight is opt-in.
  static const _defaultGroups = {
    HealthMetricGroup.activity,
    HealthMetricGroup.heartRate,
    HealthMetricGroup.sleep,
    HealthMetricGroup.workouts,
  };

  Set<HealthMetricGroup>? _selected;
  bool _isRequesting = false;
  String? _resultMessage;

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(healthConnectionProvider);

    return MemyModuleScaffold(
      key: const Key('health_permission_screen'),
      title: 'Choose what to share',
      fallbackPath: RoutePaths.health,
      child: connectionAsync.when(
        data: (connection) => _buildBody(context, connection),
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) =>
            _buildBody(context, const HealthConnectionConfig()),
      ),
    );
  }

  Set<HealthMetricGroup> _initialSelection(HealthPermissionState state) {
    final selected = <HealthMetricGroup>{...state.readableGroups};
    for (final group in _defaultGroups) {
      final d = state.dispositionOf(group);
      if (d == HealthPermissionDisposition.notRequested) {
        selected.add(group);
      }
    }
    return selected;
  }

  Widget _buildBody(BuildContext context, HealthConnectionConfig connection) {
    final selected = _selected ??= _initialSelection(
      connection.permissionState,
    );
    final isConnected =
        connection.status == IntegrationConnectionStatus.connected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (connection.recoveryNeeded) ...[
          Text(
            key: const Key('health_prefs_recovery'),
            connection.backupAvailable
                ? 'Saved Health connection settings looked damaged. '
                      'Restore from backup or reconnect — MeMy did not assume '
                      'you were disconnected.'
                : 'Saved Health connection settings looked damaged. Reconnect '
                      'to restore access — MeMy did not assume you were '
                      'disconnected.',
            style: AppTextStyles.bodyMedium(color: AppColors.emberDark),
          ),
          if (connection.backupAvailable) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('health_restore_backup_button'),
                onPressed: _isRequesting ? null : _restoreBackup,
                child: const Text('Restore from backup'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          'Every category below maps to one Health read permission. Pick '
          'only what you want MeMy to see — you can change this anytime.',
          style: AppTextStyles.bodyMedium(),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final group in HealthMetricGroup.values)
          _GroupTile(
            key: Key('health_group_${group.name}'),
            group: group,
            isSelected: selected.contains(group),
            isDenied: _isDeniedGroup(connection.permissionState, group),
            disposition: connection.permissionState.dispositionOf(group),
            onChanged: (value) {
              setState(() {
                if (value) {
                  selected.add(group);
                } else {
                  selected.remove(group);
                }
                _selected = {...selected};
              });
            },
          ),
        const SizedBox(height: AppSpacing.lg),
        if (_resultMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              _resultMessage!,
              key: const Key('health_permission_result'),
              style: AppTextStyles.bodySmall(color: AppColors.emberDark),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('health_grant_access_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ember,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.controlRadius,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: (_isRequesting || selected.isEmpty)
                ? null
                : () => _requestAccess(selected),
            child: _isRequesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Grant access'),
          ),
        ),
        if (isConnected) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('health_disconnect_button'),
              onPressed: _isRequesting ? null : _disconnect,
              child: const Text('Disconnect Health'),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const HealthDisclaimerBanner(),
      ],
    );
  }

  Future<void> _requestAccess(Set<HealthMetricGroup> groups) async {
    setState(() {
      _isRequesting = true;
      _resultMessage = null;
    });
    try {
      final state = await ref
          .read(healthConnectionControllerProvider)
          .requestPermissions(groups);
      if (!mounted) return;
      setState(() {
        _resultMessage = _successMessage(state, groups.length);
      });
      if (mounted) context.go(RoutePaths.health);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resultMessage = "Couldn't request access. Try again.";
      });
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  String _successMessage(HealthPermissionState state, int requestedCount) {
    if (state.hasFailedDispositions) {
      return "Couldn't complete the Health permission request. Try again.";
    }
    if (state.hasCancelledDispositions) {
      return 'Permission request was cancelled. Nothing was changed — tap '
          'Grant access when you are ready.';
    }
    if (state.hasUnverifiedDispositions) {
      return "Apple Health doesn't tell apps which categories you approved. "
          'MeMy will show data for anything you allowed — check Settings → '
          'Health if something is missing.';
    }
    final granted = state.verifiedGrantedCount;
    if (granted == 0) {
      return 'No categories were granted. You can change this later from '
          'your device Health settings.';
    }
    if (granted >= requestedCount) {
      return 'All set — $granted of $requestedCount categories verified.';
    }
    return '$granted of $requestedCount categories granted. '
        'You can change this later from your device Health settings.';
  }

  Future<void> _disconnect() async {
    setState(() => _isRequesting = true);
    try {
      await ref.read(healthConnectionControllerProvider).disconnect();
      if (mounted) context.go(RoutePaths.health);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _isRequesting = true);
    try {
      await ref.read(healthConnectionControllerProvider).restoreBackup();
      if (!mounted) return;
      setState(() {
        _resultMessage = 'Restored your last saved Health connection settings.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resultMessage = "Couldn't restore backup. Try reconnecting instead.";
      });
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}

bool _isDeniedGroup(HealthPermissionState state, HealthMetricGroup group) {
  final d = state.dispositionOf(group);
  return d == HealthPermissionDisposition.deniedVerified ||
      d == HealthPermissionDisposition.needsSystemSettings;
}

String? _dispositionSubtitle(HealthPermissionDisposition disposition) {
  return switch (disposition) {
    HealthPermissionDisposition.deniedVerified => 'Previously declined',
    HealthPermissionDisposition.needsSystemSettings =>
      'Change in system Health settings',
    HealthPermissionDisposition.requestCancelled => 'Request cancelled',
    HealthPermissionDisposition.requestFailed => 'Request failed',
    HealthPermissionDisposition.requestCompletedUnverified =>
      'Access unverified — data may still appear',
    _ => null,
  };
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    super.key,
    required this.group,
    required this.isSelected,
    required this.isDenied,
    required this.disposition,
    required this.onChanged,
  });

  final HealthMetricGroup group;
  final bool isSelected;
  final bool isDenied;
  final HealthPermissionDisposition disposition;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.chipRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        activeColor: AppColors.ember,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          group.label,
          style: AppTextStyles.bodyMedium(color: AppColors.primaryText),
        ),
        subtitle: _dispositionSubtitle(disposition) != null
            ? Text(
                _dispositionSubtitle(disposition)!,
                style: AppTextStyles.labelSmall(
                  color: isDenied
                      ? AppColors.faintText
                      : AppColors.secondaryText,
                ),
              )
            : null,
      ),
    );
  }
}
