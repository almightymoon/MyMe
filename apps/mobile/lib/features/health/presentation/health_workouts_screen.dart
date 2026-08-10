import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../application/providers/health_providers.dart';
import '../domain/entities/health_metric_type.dart';
import '../domain/entities/health_workout.dart';
import 'widgets/health_disclaimer_banner.dart';

/// Workouts read from the platform Health store for the selected day —
/// duration/energy/distance only, no route maps or clinical detail.
class HealthWorkoutsScreen extends ConsumerWidget {
  const HealthWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyHealthSummaryProvider);

    return MemyModuleScaffold(
      key: const Key('health_workouts_screen'),
      title: 'Workouts',
      fallbackPath: RoutePaths.health,
      child: summaryAsync.when(
        data: (summary) {
          if (summary.workouts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No workouts recorded for this day.',
                  style: AppTextStyles.bodyMedium(),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final workout in summary.workouts)
                _WorkoutRow(workout: workout),
              const SizedBox(height: AppSpacing.lg),
              const HealthDisclaimerBanner(),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              "Couldn't load workouts right now.",
              style: AppTextStyles.bodyMedium(),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.workout});

  final HealthWorkout workout;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.chipRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Icon(_iconFor(workout.activity), color: AppColors.ember),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.activity.label, style: AppTextStyles.titleSmall()),
                const SizedBox(height: 2),
                Text(
                  '${timeFormat.format(workout.startAt)} · '
                  '${workout.duration.inMinutes} min · ${workout.source.label}',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          if (workout.energyBurnedKcal != null)
            Text(
              '${workout.energyBurnedKcal!.round()} kcal',
              style: AppTextStyles.labelMedium(),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(HealthWorkoutActivity activity) {
    switch (activity) {
      case HealthWorkoutActivity.walking:
        return Icons.directions_walk_rounded;
      case HealthWorkoutActivity.running:
        return Icons.directions_run_rounded;
      case HealthWorkoutActivity.cycling:
        return Icons.directions_bike_rounded;
      case HealthWorkoutActivity.swimming:
        return Icons.pool_rounded;
      case HealthWorkoutActivity.strengthTraining:
        return Icons.fitness_center_rounded;
      case HealthWorkoutActivity.yoga:
        return Icons.self_improvement_rounded;
      case HealthWorkoutActivity.hiit:
        return Icons.bolt_rounded;
      case HealthWorkoutActivity.hiking:
        return Icons.terrain_rounded;
      case HealthWorkoutActivity.sports:
        return Icons.sports_soccer_rounded;
      case HealthWorkoutActivity.other:
        return Icons.fitness_center_rounded;
    }
  }
}
