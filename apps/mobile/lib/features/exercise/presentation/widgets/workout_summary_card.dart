import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../domain/entities/featured_workout.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({super.key, required this.summary});

  final WeeklyActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${summary.weekLabel}: ${summary.sessionsCompleted} sessions, '
          '${summary.activeMinutes} active minutes, ${summary.streakDays} day streak',
      child: MemyCard(
        key: const Key('workout_summary_card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.weekLabel, style: AppTextStyles.kicker()),
            const SizedBox(height: AppSpacing.sm),
            Text('Weekly activity', style: AppTextStyles.titleMedium()),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    value: '${summary.sessionsCompleted}',
                    label: 'Sessions',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    value: '${summary.activeMinutes}',
                    label: 'Minutes',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    value: '${summary.streakDays}',
                    label: 'Streak',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayMedium(color: AppColors.ember)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
