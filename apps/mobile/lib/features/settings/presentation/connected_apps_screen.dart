import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/integrations/application/providers/integration_providers.dart';
import '../../../core/integrations/domain/integration_connection_status.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../calendar/application/providers/calendar_providers.dart';
import '../../health/application/providers/health_providers.dart'
    as health_providers;

/// `/settings/connections` — a single place to see (and manage) every
/// device integration MeMy talks to.
class ConnectedAppsScreen extends ConsumerWidget {
  const ConnectedAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarConnection = ref.watch(calendarConnectionProvider);
    final healthAsync = ref.watch(health_providers.healthConnectionProvider);
    final healthStatus =
        healthAsync.valueOrNull?.status ??
        IntegrationConnectionStatus.notConnected;
    final recoveryCount =
        ref.watch(calendarRecoveryCasesProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      key: const Key('connected_apps'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Connected Apps',
              subtitle: 'Manage what MeMy syncs with your device',
              leading: IconButton(
                key: const Key('connected_apps_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.settings),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                children: [
                  _ConnectionRow(
                    key: const Key('connected_apps_calendar'),
                    icon: Icons.calendar_month_rounded,
                    title: 'Calendar',
                    status: calendarConnection.status,
                    onTap: () {
                      if (calendarConnection.isConnected) {
                        context.push(RoutePaths.calendar);
                      } else {
                        context.push(RoutePaths.calendarConnect);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConnectionRow(
                    key: const Key('connected_apps_health'),
                    icon: Icons.favorite_rounded,
                    title: 'Health',
                    status: healthStatus,
                    onTap: () => context.push(RoutePaths.health),
                  ),
                  if (recoveryCount > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      key: const Key('connected_apps_calendar_recovery'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.healing_rounded),
                      title: Text(
                        recoveryCount == 1
                            ? '1 calendar create recovery'
                            : '$recoveryCount calendar create recoveries',
                      ),
                      subtitle: const Text('Review ambiguous create syncs'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(RoutePaths.calendarRecovery),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ListTile(
                    key: const Key('connected_apps_diagnostics'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.monitor_heart_outlined),
                    title: const Text('Integration diagnostics'),
                    subtitle: const Text(
                      'Operational metadata only — no personal content',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        context.push(RoutePaths.integrationDiagnostics),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      key: const Key('connected_apps_lab'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.science_outlined),
                      title: const Text('Integration Lab'),
                      subtitle: const Text('Debug-only fake gateway scenarios'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(RoutePaths.integrationLab),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final IntegrationConnectionStatus status;
  final VoidCallback onTap;

  String get _statusLabel {
    switch (status) {
      case IntegrationConnectionStatus.connected:
      case IntegrationConnectionStatus.syncing:
        return 'Connected';
      case IntegrationConnectionStatus.connecting:
        return 'Connecting…';
      case IntegrationConnectionStatus.partiallyConnected:
      case IntegrationConnectionStatus.staleCacheAvailable:
      case IntegrationConnectionStatus.providerUnavailable:
      case IntegrationConnectionStatus.permissionStatusUnknown:
      case IntegrationConnectionStatus.configurationInvalid:
      case IntegrationConnectionStatus.error:
        return 'Needs attention';
      case IntegrationConnectionStatus.notConnected:
        return 'Not connected';
    }
  }

  Color get _statusColor {
    switch (status) {
      case IntegrationConnectionStatus.connected:
      case IntegrationConnectionStatus.syncing:
        return AppColors.finance;
      case IntegrationConnectionStatus.partiallyConnected:
      case IntegrationConnectionStatus.staleCacheAvailable:
      case IntegrationConnectionStatus.providerUnavailable:
      case IntegrationConnectionStatus.permissionStatusUnknown:
      case IntegrationConnectionStatus.configurationInvalid:
      case IntegrationConnectionStatus.error:
        return AppColors.health;
      case IntegrationConnectionStatus.connecting:
      case IntegrationConnectionStatus.notConnected:
        return AppColors.faintText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ember.withValues(alpha: 0.12),
              borderRadius: AppRadii.controlRadius,
            ),
            child: Icon(icon, color: AppColors.ember, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                ),
                Text(
                  _statusLabel,
                  style: AppTextStyles.bodySmall(color: _statusColor),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.navInactive),
        ],
      ),
    );
  }
}
