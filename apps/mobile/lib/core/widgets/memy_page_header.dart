import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Centered page title row matching the prototype `top-row` / `page-title`.
class MemyPageHeader extends StatelessWidget {
  const MemyPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: leading != null
                      ? Align(alignment: Alignment.centerLeft, child: leading)
                      : null,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge(),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: trailing != null
                      ? Align(alignment: Alignment.centerRight, child: trailing)
                      : null,
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ],
      ),
    );
  }
}
