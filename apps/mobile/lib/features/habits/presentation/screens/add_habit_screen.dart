import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/habit_form_controller.dart';
import '../widgets/habit_form_body.dart';

class AddHabitScreen extends ConsumerWidget {
  const AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addHabitFormControllerProvider);
    final controller = ref.read(addHabitFormControllerProvider.notifier);

    return Scaffold(
      key: const Key('add_habit_screen'),
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'New Habit',
              subtitle: 'Build a routine that sticks',
              leading: IconButton(
                key: const Key('add_habit_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.habits),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: HabitFormBody(form: form, controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: MemyPrimaryButton(
                key: const Key('habit_save_button'),
                label: form.isSubmitting ? 'Saving…' : 'Save habit',
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        final id = await controller.submitCreate();
                        if (!context.mounted || id == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Habit saved')),
                        );
                        context.pushReplacement(RoutePaths.habitDetailPath(id));
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
