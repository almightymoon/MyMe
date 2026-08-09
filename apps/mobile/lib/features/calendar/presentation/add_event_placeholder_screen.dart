import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../application/controllers/calendar_controller.dart';

class AddEventPlaceholderScreen extends ConsumerStatefulWidget {
  const AddEventPlaceholderScreen({super.key});

  @override
  ConsumerState<AddEventPlaceholderScreen> createState() =>
      _AddEventPlaceholderScreenState();
}

class _AddEventPlaceholderScreenState
    extends ConsumerState<AddEventPlaceholderScreen> {
  late final TextEditingController _title;
  late final TextEditingController _date;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _place;
  late final TextEditingController _notes;
  int? _reminderMinutes;
  String? _error;
  late DateTime _eventDate;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(calendarControllerProvider).selectedDay;
    _eventDate = DateTime(selected.year, selected.month, selected.day);
    _title = TextEditingController();
    _date = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(_eventDate),
    );
    _start = TextEditingController(text: '10:00 AM');
    _end = TextEditingController(text: '11:00 AM');
    _place = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _place.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      _eventDate = picked;
      _date.text = DateFormat('MMM dd, yyyy').format(picked);
    });
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = TimeOfDay(
      hour: start ? 10 : 11,
      minute: 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final label = MaterialLocalizations.of(context).formatTimeOfDay(
      picked,
      alwaysUse24HourFormat: false,
    );
    setState(() {
      if (start) {
        _start.text = label;
      } else {
        _end.text = label;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final err = await ref.read(calendarControllerProvider.notifier).addEvent(
          title: _title.text,
          date: _eventDate,
          start: _start.text,
          end: _end.text,
          place: _place.text,
          notes: _notes.text,
          reminderMinutes: _reminderMinutes,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final reminder = _reminderMinutes != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reminder ? 'Event saved · reminder set' : 'Event saved',
        ),
      ),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.calendar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(calendarControllerProvider).isSaving;

    return Scaffold(
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
                onPressed: saving
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.calendar),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const Key('add_event_form'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Event title', style: AppTextStyles.kicker()),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('event_title_field'),
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Team standup',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Date', style: AppTextStyles.kicker()),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('event_date_field'),
                      controller: _date,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Start time', style: AppTextStyles.kicker()),
                              const SizedBox(height: 6),
                              TextField(
                                key: const Key('event_start_field'),
                                controller: _start,
                                readOnly: true,
                                onTap: () => _pickTime(start: true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('End time', style: AppTextStyles.kicker()),
                              const SizedBox(height: 6),
                              TextField(
                                key: const Key('event_end_field'),
                                controller: _end,
                                readOnly: true,
                                onTap: () => _pickTime(start: false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Location', style: AppTextStyles.kicker()),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('event_place_field'),
                      controller: _place,
                      decoration: const InputDecoration(
                        hintText: 'Office, Google Meet…',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Notes', style: AppTextStyles.kicker()),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('event_notes_field'),
                      controller: _notes,
                      decoration: const InputDecoration(
                        hintText: 'Optional details',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Reminder', style: AppTextStyles.kicker()),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      key: const Key('event_reminder_field'),
                      // ignore: deprecated_member_use
                      value: _reminderMinutes,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('None')),
                        DropdownMenuItem(
                          value: 15,
                          child: Text('15 minutes before'),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text('30 minutes before'),
                        ),
                        DropdownMenuItem(
                          value: 60,
                          child: Text('1 hour before'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _reminderMinutes = v),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        key: const Key('event_error'),
                        style: AppTextStyles.bodySmall(
                          color: AppColors.health,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    MemyPrimaryButton(
                      key: const Key('event_save'),
                      label: saving ? 'Saving…' : 'Save Event',
                      onPressed: saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
