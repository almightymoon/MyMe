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

/// Step 2 of the connect flow — pick which device calendars to sync, then
/// runs the initial import (past 30 / future 365 days).
class CalendarSelectionScreen extends ConsumerStatefulWidget {
  const CalendarSelectionScreen({super.key, required this.calendars});

  final List<DeviceCalendarDescriptor> calendars;

  @override
  ConsumerState<CalendarSelectionScreen> createState() =>
      _CalendarSelectionScreenState();
}

class _CalendarSelectionScreenState
    extends ConsumerState<CalendarSelectionScreen> {
  final Set<String> _selected = {};
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      widget.calendars.where((c) => c.isDefault).map((c) => c.id),
    );
    if (_selected.isEmpty && widget.calendars.isNotEmpty) {
      _selected.add(widget.calendars.first.id);
    }
  }

  Future<void> _confirm() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Choose at least one calendar to sync.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final service = ref.read(calendarSyncServiceProvider);
      await service.confirmCalendarSelection(_selected.toList());
      await service.performInitialSync();
      if (!mounted) return;
      context.go(RoutePaths.calendar);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = userFacingErrorMessage(error);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('calendar_selection'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Choose Calendars',
              subtitle: 'Pick which calendars to sync with MeMy',
              leading: IconButton(
                key: const Key('calendar_selection_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.calendarConnect),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  120,
                ),
                children: [
                  for (final calendar in widget.calendars)
                    MemyCard(
                      key: Key('calendar_option_${calendar.id}'),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: EdgeInsets.zero,
                      child: CheckboxListTile(
                        value: _selected.contains(calendar.id),
                        title: Text(
                          calendar.name,
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 15,
                          ),
                        ),
                        subtitle: calendar.accountName == null
                            ? null
                            : Text(
                                calendar.accountName!,
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.faintText,
                                ),
                              ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selected.add(calendar.id);
                            } else {
                              _selected.remove(calendar.id);
                            }
                          });
                        },
                      ),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      key: const Key('calendar_selection_error'),
                      style: AppTextStyles.bodySmall(color: AppColors.health),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  MemyPrimaryButton(
                    key: const Key('calendar_selection_confirm'),
                    label: _saving ? 'Syncing…' : 'Start syncing',
                    onPressed: _saving ? null : _confirm,
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
