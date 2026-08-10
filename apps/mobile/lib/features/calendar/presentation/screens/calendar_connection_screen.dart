import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/calendar_providers.dart';
import '../../domain/entities/device_calendar_descriptor.dart';

/// Step 1 of the connect flow — requests permission and, on success,
/// hands the returned device calendars off to [CalendarSelectionScreen].
class CalendarConnectionScreen extends ConsumerStatefulWidget {
  const CalendarConnectionScreen({super.key});

  @override
  ConsumerState<CalendarConnectionScreen> createState() =>
      _CalendarConnectionScreenState();
}

class _CalendarConnectionScreenState
    extends ConsumerState<CalendarConnectionScreen> {
  var _connecting = false;
  String? _error;
  List<DeviceCalendarDescriptor>? _calendars;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final calendars = await ref
          .read(calendarSyncServiceProvider)
          .beginConnection();
      if (!mounted) return;
      setState(() {
        _calendars = calendars;
        _connecting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = userFacingErrorMessage(error);
        _connecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendars = _calendars;

    return Scaffold(
      key: const Key('calendar_connection'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Connect Calendar',
              subtitle: 'Sync events from your device calendar',
              leading: IconButton(
                key: const Key('calendar_connection_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.calendar),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                children: [
                  MemyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MeMy will ask for permission to read and write '
                          'events on calendars you choose. Event content '
                          'never leaves your device.',
                          style: AppTextStyles.bodyMedium(),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _error!,
                            key: const Key('calendar_connection_error'),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.health,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (calendars == null)
                          MemyPrimaryButton(
                            key: const Key('calendar_connect_button'),
                            label: _connecting
                                ? 'Connecting…'
                                : 'Connect calendar',
                            onPressed: _connecting ? null : _connect,
                          )
                        else if (calendars.isEmpty)
                          Text(
                            'No calendars were found on this device.',
                            style: AppTextStyles.bodyMedium(),
                          )
                        else
                          MemyPrimaryButton(
                            key: const Key('calendar_choose_calendars_button'),
                            label: 'Choose calendars',
                            onPressed: () => context.push(
                              RoutePaths.calendarSelection,
                              extra: calendars,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
