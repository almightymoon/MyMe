import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/profile_avatar.dart';

class ProfileAvatarView extends StatelessWidget {
  const ProfileAvatarView({
    super.key,
    required this.avatarId,
    this.size = 56,
    this.selected = false,
  });

  final String avatarId;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final spec = ProfileAvatarCatalog.byId(avatarId);
    final ring = selected ? 3.0 : 0.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.orangeSoft,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: selected ? AppColors.ember : Colors.transparent,
          width: ring,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(ring),
        child: ClipOval(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: SizedBox.expand(
            child: Transform.scale(
              // Artwork is a circle on a square canvas; scale past the
              // jagged baked-in edge so the widget ring is a clean circle.
              scale: 1.18,
              child: Image.asset(
                spec.assetPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: AppColors.orangeSoft,
                    child: Icon(
                      Icons.person_rounded,
                      size: size * 0.45,
                      color: AppColors.emberDark,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.enabled = true,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('profile_avatar_picker'),
      spacing: 12,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: [
        for (final spec in ProfileAvatarCatalog.all)
          Semantics(
            button: true,
            selected: spec.id == selectedId,
            label: 'Avatar ${spec.label}',
            child: InkWell(
              key: Key('profile_avatar_${spec.id}'),
              customBorder: const CircleBorder(),
              onTap: enabled ? () => onSelected(spec.id) : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ProfileAvatarView(
                    avatarId: spec.id,
                    size: 64,
                    selected: spec.id == selectedId,
                  ),
                  if (spec.id == selectedId)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.ember,
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
