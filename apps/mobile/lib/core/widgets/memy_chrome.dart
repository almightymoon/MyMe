import 'package:flutter/material.dart';

import '../../app/router/app_navigation.dart';
import '../../app/theme/app_colors.dart';

/// Soft circular menu control (prototype `.icon-circle`).
///
/// Always sits on the **far right** of chrome rows and opens the end drawer.
class MemyMenuButton extends StatelessWidget {
  const MemyMenuButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.hairline,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: AppColors.ember.withValues(alpha: 0.10),
        highlightColor: AppColors.ember.withValues(alpha: 0.06),
        onTap: onPressed ?? () => openMemyDrawer(context),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.menu_rounded,
            size: 20,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}

/// Circular profile avatar that opens Profile.
class MemyAvatarButton extends StatelessWidget {
  const MemyAvatarButton({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => openMemyProfile(context),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orangeSoft,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/branding/avatar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

/// Right-side chrome: optional leading actions, optional avatar, then menu.
///
/// Menu is always the rightmost control.
class MemyHeaderActions extends StatelessWidget {
  const MemyHeaderActions({
    super.key,
    this.showAvatar = true,
    this.avatarSize = 44,
    this.leading = const [],
    this.menuKey,
    this.avatarKey,
  });

  final bool showAvatar;
  final double avatarSize;
  final List<Widget> leading;
  final Key? menuKey;
  final Key? avatarKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < leading.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          leading[i],
        ],
        if (leading.isNotEmpty && showAvatar) const SizedBox(width: 8),
        if (showAvatar) ...[
          KeyedSubtree(
            key: avatarKey ?? const Key('memy_avatar_button'),
            child: MemyAvatarButton(size: avatarSize),
          ),
          const SizedBox(width: 8),
        ],
        KeyedSubtree(
          key: menuKey ?? const Key('memy_menu_button'),
          child: const MemyMenuButton(),
        ),
      ],
    );
  }
}
