import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/integrations/domain/integration_diagnostics_report.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../calendar/application/providers/calendar_providers.dart';
import '../application/providers/diagnostics_providers.dart';

/// `/settings/connections/diagnostics` — operational metadata only.
class IntegrationDiagnosticsScreen extends ConsumerWidget {
  const IntegrationDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(integrationDiagnosticsProvider);
    final recoveryCount =
        ref.watch(calendarRecoveryCasesProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      key: const Key('integration_diagnostics'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Integration diagnostics',
              subtitle: 'Operational metadata only — no personal content',
              leading: IconButton(
                key: const Key('integration_diagnostics_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.connectedApps),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Text(
                      'Could not load diagnostics.',
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ),
                ),
                data: (report) =>
                    _Body(report: report, recoveryCount: recoveryCount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report, required this.recoveryCount});

  final IntegrationDiagnosticsReport report;
  final int recoveryCount;

  @override
  Widget build(BuildContext context) {
    final json = const JsonEncoder.withIndent('  ').convert(report.toJson());

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          'This screen never includes event titles, Health values, device IDs, '
          'or account emails.',
          style: AppTextStyles.bodySmall().copyWith(color: AppColors.faintText),
        ),
        if (recoveryCount > 0) ...[
          const SizedBox(height: AppSpacing.md),
          ListTile(
            key: const Key('integration_diagnostics_calendar_recovery'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.healing_rounded),
            title: Text(
              recoveryCount == 1
                  ? '1 calendar create recovery'
                  : '$recoveryCount calendar create recoveries',
            ),
            subtitle: const Text('Open create-recovery review'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(RoutePaths.calendarRecovery),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: 'App',
          rows: [
            ('OS', '${report.app.osFamily} ${report.app.osVersion}'),
            ('Timezone', report.app.timezone),
            ('Locale', report.app.locale),
            ('Debug build', report.app.isDebugBuild ? 'yes' : 'no'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: 'Calendar',
          rows: [
            ('Gateway', report.calendar.gatewayMode),
            ('Availability', report.calendar.availability),
            ('Status', report.calendar.connectionStatus),
            ('Readable calendars', '${report.calendar.readableCalendarCount}'),
            (
              'Writable target',
              report.calendar.hasValidWritableTarget ? 'configured' : 'missing',
            ),
            ('Schema', 'v${report.calendar.calendarSchemaVersion}'),
            ('Pending ops', '${report.calendar.pendingOperationCount}'),
            ('Unknown outcomes', '${report.calendar.unknownOutcomeCount}'),
            ('Needs user action', '${report.calendar.requiresUserActionCount}'),
            ('Conflicts', '${report.calendar.conflictCount}'),
            ('Create recoveries', '${report.calendar.unresolvedRecoveryCount}'),
            ('Suspected missing', '${report.calendar.suspectedMissingCount}'),
            ('Confirmed missing', '${report.calendar.confirmedMissingCount}'),
            (
              'Last pull',
              report.calendar.lastSuccessfulPullAt?.toUtc().toIso8601String() ??
                  '—',
            ),
            (
              'Last push',
              report.calendar.lastSuccessfulPushAt?.toUtc().toIso8601String() ??
                  '—',
            ),
            ('Error code', report.calendar.lastErrorCode ?? '—'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: 'Health',
          rows: [
            ('Gateway', report.health.gatewayMode),
            ('Availability', report.health.availability),
            ('Status', report.health.connectionStatus),
            ('Schema', 'v${report.health.configSchemaVersion}'),
            ('Recovery needed', report.health.recoveryNeeded ? 'yes' : 'no'),
            ('Backup available', report.health.backupAvailable ? 'yes' : 'no'),
            (
              'Last refresh',
              report.health.lastSuccessfulRefreshAt
                      ?.toUtc()
                      .toIso8601String() ??
                  '—',
            ),
            ('Error code', report.health.lastErrorCode ?? '—'),
            for (final entry in report.health.permissionDispositions.entries)
              ('Perm ${entry.key}', entry.value),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('integration_diagnostics_copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redacted diagnostics copied to clipboard'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy redacted JSON'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          key: const Key('integration_diagnostics_json'),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.panelRadius,
          ),
          child: SelectableText(json, style: AppTextStyles.mono(fontSize: 11)),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.sm),
          for (final row in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    row.$1,
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.faintText,
                    ),
                  ),
                ),
                Expanded(child: Text(row.$2, style: AppTextStyles.bodySmall())),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}
