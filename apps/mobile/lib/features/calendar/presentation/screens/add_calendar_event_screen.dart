import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/calendar_event_form_controller.dart';
import '../widgets/calendar_event_form_body.dart';

class AddCalendarEventScreen extends ConsumerWidget {
  const AddCalendarEventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addCalendarEventControllerProvider);
    final controller = ref.read(addCalendarEventControllerProvider.notifier);

    return Scaffold(
      key: const Key('add_calendar_event'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: AppStrings.addEvent,
              subtitle: 'Schedule something on your calendar',
              leading: IconButton(
                key: const Key('add_event_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.calendar),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: CalendarEventFormBody(
                form: form,
                controller: controller,
                onSave: () async {
                  final id = await controller.save();
                  if (!context.mounted || id == null) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Event saved')));
                  context.go(RoutePaths.eventDetailPath(id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
