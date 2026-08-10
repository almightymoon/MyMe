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
import '../../../../core/widgets/section_header.dart';
import '../../application/providers/calendar_providers.dart';
import '../../domain/entities/device_calendar_descriptor.dart';

/// Step 2 of the connect flow — pick readable calendars (multi) and a single
/// writable destination, optionally creating a dedicated MeMy calendar.
class CalendarSelectionScreen extends ConsumerStatefulWidget {
  const CalendarSelectionScreen({super.key, required this.calendars});

  final List<DeviceCalendarDescriptor> calendars;

  @override
  ConsumerState<CalendarSelectionScreen> createState() =>
      _CalendarSelectionScreenState();
}

class _CalendarSelectionScreenState
    extends ConsumerState<CalendarSelectionScreen> {
  final Set<String> _readable = {};
  String? _writableId;
  var _calendars = <DeviceCalendarDescriptor>[];
  var _saving = false;
  var _creating = false;
  var _supportsCreation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calendars = List.of(widget.calendars);
    _readable.addAll(_calendars.where((c) => c.isDefault).map((c) => c.id));
    if (_readable.isEmpty && _calendars.isNotEmpty) {
      _readable.add(_calendars.first.id);
    }
    final writableCandidates = _calendars
        .where((c) => !c.isReadOnly)
        .toList(growable: false);
    if (writableCandidates.isNotEmpty) {
      final preferred = writableCandidates.firstWhere(
        (c) => _readable.contains(c.id),
        orElse: () => writableCandidates.first,
      );
      _writableId = preferred.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCreationSupport());
  }

  Future<void> _loadCreationSupport() async {
    final supported = await ref
        .read(deviceCalendarGatewayProvider)
        .supportsCalendarCreation();
    if (!mounted) return;
    setState(() => _supportsCreation = supported);
  }

  Future<void> _createMeMyCalendar() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final created = await ref
          .read(deviceCalendarGatewayProvider)
          .createCalendar(name: 'MeMy');
      if (!mounted) return;
      setState(() {
        _calendars = [..._calendars, created];
        _readable.add(created.id);
        _writableId = created.id;
        _creating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = userFacingErrorMessage(error);
        _creating = false;
      });
    }
  }

  Future<void> _confirm() async {
    if (_readable.isEmpty) {
      setState(() => _error = 'Choose at least one calendar to read.');
      return;
    }
    if (_writableId == null) {
      setState(
        () => _error =
            'Choose a writable calendar for events you create in MeMy.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final service = ref.read(calendarSyncServiceProvider);
      final dedicatedMatch = _calendars.where(
        (c) => c.id == _writableId && c.name == 'MeMy',
      );
      final dedicated = dedicatedMatch.isEmpty ? null : dedicatedMatch.first.id;
      await service.confirmCalendarSelection(
        readableIds: _readable.toList(),
        writableId: _writableId,
        dedicatedId: dedicated,
      );
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
              subtitle: 'Pick calendars to read and where MeMy writes',
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
                  const SectionHeader(title: 'Read from'),
                  Text(
                    'Imported events stay read-only in MeMy.',
                    style: AppTextStyles.bodySmall(color: AppColors.faintText),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final calendar in _calendars)
                    MemyCard(
                      key: Key('calendar_option_${calendar.id}'),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: EdgeInsets.zero,
                      child: CheckboxListTile(
                        value: _readable.contains(calendar.id),
                        title: Text(
                          calendar.name,
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (calendar.accountName != null)
                              calendar.accountName!,
                            if (calendar.isReadOnly) 'Read-only',
                          ].join(' · '),
                          style: AppTextStyles.bodySmall(
                            color: AppColors.faintText,
                          ),
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _readable.add(calendar.id);
                            } else {
                              _readable.remove(calendar.id);
                            }
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(title: 'Write to'),
                  Text(
                    'MeMy-created events sync to this calendar only.',
                    style: AppTextStyles.bodySmall(color: AppColors.faintText),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RadioGroup<String>(
                    groupValue: _writableId,
                    onChanged: (value) => setState(() => _writableId = value),
                    child: Column(
                      children: [
                        for (final calendar in _calendars)
                          MemyCard(
                            key: Key('calendar_writable_${calendar.id}'),
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: EdgeInsets.zero,
                            child: RadioListTile<String>(
                              value: calendar.id,
                              enabled: !calendar.isReadOnly,
                              title: Text(
                                calendar.name,
                                style: AppTextStyles.titleMedium().copyWith(
                                  fontSize: 15,
                                  color: calendar.isReadOnly
                                      ? AppColors.faintText
                                      : null,
                                ),
                              ),
                              subtitle: calendar.isReadOnly
                                  ? Text(
                                      'Read-only — cannot write',
                                      style: AppTextStyles.bodySmall(
                                        color: AppColors.faintText,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_supportsCreation) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      key: const Key('calendar_create_memy'),
                      onPressed: _creating ? null : _createMeMyCalendar,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        _creating ? 'Creating…' : 'Create MeMy calendar',
                      ),
                    ),
                  ],
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
