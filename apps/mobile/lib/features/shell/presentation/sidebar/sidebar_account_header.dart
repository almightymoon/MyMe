import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';

/// Profile block at the top of the MeMy sidebar drawer.
class SidebarAccountHeader extends StatelessWidget {
  const SidebarAccountHeader({
    super.key,
    required this.displayName,
    required this.emailLabel,
    required this.onViewProfile,
    this.showDemoBadge = true,
  });

  final String displayName;
  final String emailLabel;
  final VoidCallback onViewProfile;
  final bool showDemoBadge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDemoBadge) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              key: const Key('drawer_demo_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: AppRadii.pillRadius,
              ),
              child: Text(
                AppStrings.demoMode,
                style: AppTextStyles.bodySmall().copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.emberDark,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orangeSoft,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage('assets/images/branding/avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.titleMedium().copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emailLabel,
                    style: AppTextStyles.bodySmall().copyWith(
                      fontSize: 12,
                      color: AppColors.faintText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const Key('drawer_view_profile'),
                    onPressed: onViewProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      side: const BorderSide(color: AppColors.line),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, AppSpacing.minTouch),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const StadiumBorder(),
                      textStyle: AppTextStyles.bodySmall().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Profile'),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
