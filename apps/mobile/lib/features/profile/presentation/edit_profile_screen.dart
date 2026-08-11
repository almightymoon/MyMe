import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../../user/presentation/widgets/profile_avatar_view.dart';
import '../application/edit_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(editProfileControllerProvider).displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(editProfileControllerProvider);
    final controller = ref.read(editProfileControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit profile',
              subtitle: 'Saved on this device',
              leading: IconButton(
                key: const Key('edit_profile_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.profile),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('edit_profile_form'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (form.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(form.errorMessage!),
                      ),
                    Center(
                      child: ProfileAvatarView(
                        avatarId: form.avatarId,
                        size: 88,
                        selected: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      key: const Key('edit_profile_name_field'),
                      controller: _nameController,
                      enabled: !form.isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Display name',
                        errorText: form.fieldErrors['displayName'],
                      ),
                      onChanged: controller.setDisplayName,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choose an avatar',
                      style: AppTextStyles.titleSmall().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Photos stay off this profile. Pick one of these instead.',
                      style: AppTextStyles.bodySmall(),
                    ),
                    if (form.fieldErrors['avatarId'] != null) ...[
                      const SizedBox(height: 6),
                      Text(form.fieldErrors['avatarId']!),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    ProfileAvatarPicker(
                      selectedId: form.avatarId,
                      enabled: !form.isSubmitting,
                      onSelected: controller.setAvatarId,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: MemyPrimaryButton(
                key: const Key('edit_profile_save_button'),
                label: form.isSubmitting ? 'Saving…' : 'Save profile',
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        controller.setDisplayName(_nameController.text);
                        final saved = await controller.submit();
                        if (!context.mounted || !saved) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile saved on this device'),
                          ),
                        );
                        memyBack(context, fallback: RoutePaths.profile);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
