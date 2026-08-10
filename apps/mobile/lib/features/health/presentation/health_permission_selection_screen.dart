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

  Widget _buildBody(BuildContext context, HealthConnectionConfig connection) {
    final selected = _selected ??= {
      ...connection.permissionState.grantedGroups,
      ...HealthMetricGroup.values.where(
        (g) =>
            !connection.permissionState.grantedGroups.contains(g) &&
            !connection.permissionState.deniedGroups.contains(g),
      ),
    };
    final isConnected =
        connection.status == IntegrationConnectionStatus.connected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            isDenied: connection.permissionState.deniedGroups.contains(group),
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
      final granted = await ref
          .read(healthConnectionControllerProvider)
          .requestPermissions(groups);
      if (!mounted) return;
      final deniedCount = groups.length - granted.length;
      setState(() {
        _resultMessage = deniedCount == 0
            ? 'All set — access granted.'
            : '${granted.length} of ${groups.length} categories granted. '
                  'You can change this later from your device Health settings.';
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

  Future<void> _disconnect() async {
    setState(() => _isRequesting = true);
    try {
      await ref.read(healthConnectionControllerProvider).disconnect();
      if (mounted) context.go(RoutePaths.health);
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    super.key,
    required this.group,
    required this.isSelected,
    required this.isDenied,
    required this.onChanged,
  });

  final HealthMetricGroup group;
  final bool isSelected;
  final bool isDenied;
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
        subtitle: isDenied
            ? Text(
                'Previously declined',
                style: AppTextStyles.labelSmall(color: AppColors.faintText),
              )
            : null,
      ),
    );
  }
}
