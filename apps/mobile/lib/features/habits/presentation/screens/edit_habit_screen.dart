import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/habit_form_controller.dart';
import '../../application/providers/habit_providers.dart';
import '../widgets/habit_form_body.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  const EditHabitScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  var _hydrated = false;

  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitByIdProvider(widget.habitId));
    final form = ref.watch(editHabitFormControllerProvider(widget.habitId));
    final controller = ref.read(
      editHabitFormControllerProvider(widget.habitId).notifier,
    );

    return Scaffold(
      key: const Key('edit_habit_screen'),
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit Habit',
              subtitle: 'Update schedule and goal',
              leading: IconButton(
                key: const Key('edit_habit_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.habitDetailPath(widget.habitId),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: habitAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.page),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => InlineErrorCard(
                  message: userFacingErrorMessage(error),
                  onRetry: () =>
                      ref.invalidate(habitByIdProvider(widget.habitId)),
                ),
                data: (habit) {
                  if (habit == null) {
                    return InlineErrorCard(
                      message: 'This habit is no longer available.',
                      onRetry: () => context.go(RoutePaths.habits),
                    );
                  }
                  if (!_hydrated) {
                    _hydrated = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.hydrate(habit);
                    });
                  }
                  return HabitFormBody(form: form, controller: controller);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: MemyPrimaryButton(
                key: const Key('habit_update_button'),
                label: form.isSubmitting ? 'Saving…' : 'Save changes',
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        final id = await controller.submitUpdate();
                        if (!context.mounted || id == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Habit updated')),
                        );
                        context.pop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
