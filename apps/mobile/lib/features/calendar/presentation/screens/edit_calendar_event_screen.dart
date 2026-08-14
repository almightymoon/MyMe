import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/calendar_event_form_controller.dart';
import '../../application/providers/calendar_providers.dart';
import '../widgets/calendar_event_form_body.dart';

class EditCalendarEventScreen extends ConsumerStatefulWidget {
  const EditCalendarEventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EditCalendarEventScreen> createState() =>
      _EditCalendarEventScreenState();
}

class _EditCalendarEventScreenState
    extends ConsumerState<EditCalendarEventScreen> {
  var _hydrated = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(calendarEventByIdProvider(widget.eventId));
    final form = ref.watch(editCalendarEventControllerProvider(widget.eventId));
    final controller = ref.read(
      editCalendarEventControllerProvider(widget.eventId).notifier,
    );

    return Scaffold(
      key: const Key('edit_calendar_event'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit Event',
              subtitle: 'Update this event',
              leading: IconButton(
                key: const Key('edit_event_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.eventDetailPath(widget.eventId),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: eventAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: InlineErrorCard(
                    message: userFacingErrorMessage(error),
                    onRetry: () => ref.invalidate(
                      calendarEventByIdProvider(widget.eventId),
                    ),
                  ),
                ),
                data: (event) {
                  if (event == null) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: InlineErrorCard(
                        key: const Key('edit_event_missing'),
                        message: 'This event is no longer available.',
                        onRetry: () => context.go(RoutePaths.calendar),
                      ),
                    );
                  }
                  if (!_hydrated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _hydrated) return;
                      controller.hydrate(event);
                      setState(() => _hydrated = true);
                    });
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: LoadingCardSkeleton(height: 160, lines: 4),
                    );
                  }
                  return CalendarEventFormBody(
                    key: ValueKey('edit_event_form_${event.id}'),
                    form: form,
                    controller: controller,
                    saveLabel: 'Save changes',
                    onSave: () async {
                      final id = await controller.save();
                      if (!context.mounted || id == null) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event updated')),
                      );
                      context.go(RoutePaths.eventDetailPath(id));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
