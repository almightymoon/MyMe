import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';

/// Version line + Log Out control at the bottom of the sidebar drawer.
class SidebarFooter extends StatelessWidget {
  const SidebarFooter({
    super.key,
    required this.versionLabel,
    required this.onLogout,
  });

  final String versionLabel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, AppSpacing.sm),
          child: Text(
            '${AppStrings.appName} · v$versionLabel',
            key: const Key('drawer_version'),
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 11,
              color: AppColors.faintText,
            ),
          ),
        ),
        Material(
          color: AppColors.dangerSoft,
          borderRadius: AppRadii.pillRadius,
          child: InkWell(
            key: const Key('drawer_logout'),
            borderRadius: AppRadii.pillRadius,
            onTap: onLogout,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFE5484D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: AppTextStyles.titleMedium().copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE5484D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
