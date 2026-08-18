import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/core_providers.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/integrations/domain/integration_connection_status.dart';
import '../../../core/widgets/memy_busy_indicator.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../user/application/providers/user_providers.dart';
import '../application/providers/health_providers.dart';
import '../domain/entities/daily_health_summary.dart';
import '../domain/entities/health_connection_config.dart';
import '../domain/entities/health_metric_type.dart';
import 'widgets/health_disclaimer_banner.dart';
import 'widgets/health_format.dart';
import 'widgets/health_metric_tile.dart';

/// Live Health overview — real data from [HealthRepository], with explicit
/// disconnected/partial-permission states, source attribution, and a
/// freshness label. Never shows a hardcoded/simulated reading.
class HealthOverviewScreen extends ConsumerWidget {
  const HealthOverviewScreen({super.key});

  static BoxDecoration get _peachWash => BoxDecoration(
    color: AppColors.canvas,
    gradient: RadialGradient(
      center: const Alignment(0.55, -0.15),
      radius: 0.95,
      colors: [AppColors.orangeSoft.withValues(alpha: 0.55), AppColors.canvas],
      stops: const [0.0, 0.62],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(healthConnectionProvider);
    final summaryAsync = ref.watch(dailyHealthSummaryProvider);

    return MemyModuleScaffold(
      key: const Key('health_overview'),
      title: 'Health Overview',
      decoration: _peachWash,
      trailing: MemyIconPlain(
        icon: Icons.refresh_rounded,
        showBadge: false,
        onPressed: () async {
          await ref.read(healthConnectionControllerProvider).refresh();
          ref.invalidate(dailyHealthSummaryProvider);
          ref.invalidate(healthConnectionProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshing Health data…')),
            );
          }
        },
      ),
      child: connectionAsync.when(
        data: (connection) =>
            _Body(connection: connection, summaryAsync: summaryAsync),
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: MemyBusyIndicator()),
        ),
        error: (error, _) => _Body(
          connection: const HealthConnectionConfig(),
          summaryAsync: summaryAsync,
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.connection, required this.summaryAsync});

  final HealthConnectionConfig connection;
  final AsyncValue<DailyHealthSummary> summaryAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(appClockProvider).now();
    final isConnected =
        connection.status == IntegrationConnectionStatus.connected;
    final usesAppleHealth = ref
        .watch(releaseCapabilitiesProvider)
        .usesAppleHealth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your wellness today',
          style: AppTextStyles.displayMedium().copyWith(fontSize: 24),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isConnected) ...[
          summaryAsync.when(
            data: (summary) => _ConnectedContent(
              summary: summary,
              connection: connection,
              now: now,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: MemyBusyIndicator()),
            ),
            error: (error, _) => Container(
              key: const Key('health_error'),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.panelRadius,
              ),
              child: Text(
                "Couldn't load Health data right now. Pull to refresh or "
                'try again shortly.',
                style: AppTextStyles.bodyMedium(),
              ),
            ),
          ),
        ] else if (usesAppleHealth)
          const _ConnectCallout(key: Key('health_connect_cta'))
        else
          const _InAppHealthCallout(key: Key('health_in_app_cta')),
        const SizedBox(height: AppSpacing.xl),
        const HealthDisclaimerBanner(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ConnectCallout extends StatelessWidget {
  const _ConnectCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.ember, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text('Connect Apple Health', style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'See your steps, heart rate, sleep and more here — read-only, '
            'never shared, and you choose exactly what to share.',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('health_connect_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ember,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.controlRadius,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => context.push(RoutePaths.healthConnect),
              child: const Text('Connect Health'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InAppHealthCallout extends StatelessWidget {
  const _InAppHealthCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.ember, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text('Health stays in MeMy', style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Track wellness with Habits and Exercise. MeMy does not use '
            'Health Connect.',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('health_open_habits'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ember,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.controlRadius,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => context.push(RoutePaths.habits),
              child: const Text('Open Habits'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('health_open_exercise'),
              onPressed: () => context.push(RoutePaths.exercise),
              child: const Text('Open Exercise'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedContent extends ConsumerWidget {
  const _ConnectedContent({
    required this.summary,
    required this.connection,
    required this.now,
  });

  final DailyHealthSummary summary;
  final HealthConnectionConfig connection;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metric =
        ref.watch(measurementUnitsProvider) == MeasurementUnits.metric;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (connection.permissionState.hasUnverifiedDispositions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              key: const Key('health_unverified_notice'),
              'Some categories have unverified access — Apple Health does not '
              'confirm which reads were approved.',
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
          ),
        if (connection.permissionState.deniedGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              key: const Key('health_revoked_notice'),
              'Some categories were declined or revoked — open Manage access to '
              'change permissions.',
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                HealthFormat.freshness(summary.generatedAt, now),
                style: AppTextStyles.bodySmall(),
              ),
            ),
            TextButton(
              key: const Key('health_manage_permissions'),
              onPressed: () => context.push(RoutePaths.healthPermissions),
              child: const Text('Manage access'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          key: const Key('health_metrics_grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            HealthMetricTile(
              label: 'Heart Rate',
              value: summary.latestHeartRateBpm == null
                  ? null
                  : HealthFormat.beatsPerMinute(summary.latestHeartRateBpm!),
              unit: 'bpm',
              icon: Icons.favorite_rounded,
              isPermitted: summary.isAvailable(HealthMetricType.heartRate),
            ),
            HealthMetricTile(
              label: 'Steps',
              value: summary.steps == null
                  ? null
                  : HealthFormat.steps(summary.steps!),
              icon: Icons.directions_walk_rounded,
              isPermitted: summary.isAvailable(HealthMetricType.steps),
            ),
            HealthMetricTile(
              label: 'Active Energy',
              value: summary.activeEnergyKcal == null
                  ? null
                  : HealthFormat.kilocalories(summary.activeEnergyKcal!),
              unit: 'kcal',
              icon: Icons.local_fire_department_rounded,
              isPermitted: summary.isAvailable(
                HealthMetricType.activeEnergyBurned,
              ),
            ),
            HealthMetricTile(
              label: 'Sleep (asleep)',
              value: summary.sleepDuration == null
                  ? null
                  : HealthFormat.duration(summary.sleepDuration!),
              icon: Icons.bedtime_rounded,
              isPermitted: summary.isAvailable(HealthMetricType.sleep),
            ),
            HealthMetricTile(
              label: 'Distance',
              value: summary.distanceMeters == null
                  ? null
                  : HealthFormat.distance(
                      summary.distanceMeters!,
                      metric: metric,
                    ),
              icon: Icons.map_outlined,
              isPermitted: summary.isAvailable(
                HealthMetricType.distanceWalkingRunning,
              ),
            ),
            HealthMetricTile(
              label: 'Weight',
              value: summary.weightKg == null
                  ? null
                  : HealthFormat.weightValue(summary.weightKg!, metric: metric),
              unit: HealthFormat.weightUnit(metric: metric),
              icon: Icons.monitor_weight_outlined,
              isPermitted: summary.isAvailable(HealthMetricType.weight),
            ),
          ],
        ),
        if (summary.workouts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('health_see_workouts'),
              onPressed: () => context.push(RoutePaths.healthWorkouts),
              child: Text(
                '${summary.workouts.length} workout(s) today · See all',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
