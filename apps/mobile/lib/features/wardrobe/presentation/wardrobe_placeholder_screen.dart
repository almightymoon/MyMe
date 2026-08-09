import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../../app/theme/app_radii.dart';

class WardrobePlaceholderScreen extends StatelessWidget {
  const WardrobePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MemyModuleScaffold(
      key: const Key('wardrobe_overview'),
      title: 'Wardrobe',
      heroAsset: 'assets/images/modules/mod-wardrobe.png',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Wear Decision',
            style: AppTextStyles.kicker(color: AppColors.ember),
          ),
          const SizedBox(height: 4),
          Text(
            'MeMy checked your day before choosing',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text('22°C', style: AppTextStyles.mono(fontSize: 22)),
                      Text(
                        'Cloudy',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(
                        'Team Meeting',
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '10:00 AM',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final style in [
                  ('Smart', true),
                  ('Casual', false),
                  ('Formal', false),
                  ('Minimal', false),
                  ('Date', false),
                  ('Workout', false),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: style.$2 ? AppColors.ember : AppColors.surface,
                        borderRadius: AppRadii.pillRadius,
                        boxShadow: style.$2 ? null : AppColors.softShadow,
                      ),
                      child: Text(
                        style.$1,
                        style: AppTextStyles.labelSmall(
                          color: style.$2
                              ? Colors.white
                              : AppColors.primaryText,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orangeSoft,
                              borderRadius: AppRadii.pillRadius,
                            ),
                            child: Text(
                              "Today's pick",
                              style: AppTextStyles.labelSmall(
                                color: AppColors.ember,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Meeting Look',
                            style: AppTextStyles.titleLarge().copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '97',
                          style: AppTextStyles.mono(fontSize: 28).copyWith(
                            color: AppColors.ember,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'FIT SCORE',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.faintText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '• Navy blazer\n• White oxford shirt\n• Charcoal trousers\n• Leather loafers',
                  style: AppTextStyles.bodyMedium().copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ember,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.controlRadius,
                    ),
                  ),
                  child: const Text('Wear this'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why MeMy picked this',
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your meeting is at 10 AM and it's 22°C. This combination keeps you comfortable while looking professional.",
                  style: AppTextStyles.bodySmall(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
