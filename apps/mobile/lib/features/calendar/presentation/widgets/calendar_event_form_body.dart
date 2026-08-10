import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/calendar_event_form_controller.dart';

class CalendarEventFormBody extends StatefulWidget {
  const CalendarEventFormBody({
    super.key,
    required this.form,
    required this.controller,
    required this.onSave,
    this.saveLabel = 'Save Event',
  });

  final CalendarEventFormState form;
  final CalendarEventFormController controller;
  final Future<void> Function() onSave;
  final String saveLabel;

  @override
  State<CalendarEventFormBody> createState() => _CalendarEventFormBodyState();
}

class _CalendarEventFormBodyState extends State<CalendarEventFormBody> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.form.title);
    _location = TextEditingController(text: widget.form.location);
    _notes = TextEditingController(text: widget.form.notes);
  }

  @override
  void didUpdateWidget(CalendarEventFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form.editing?.id != widget.form.editing?.id) {
      _title.text = widget.form.title;
      _location.text = widget.form.location;
      _notes.text = widget.form.notes;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.form.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    widget.controller.setDate(picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = start ? widget.form.startTime : widget.form.endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    if (start) {
      widget.controller.setStartTime(picked);
    } else {
      widget.controller.setEndTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;

    return SingleChildScrollView(
      key: const Key('calendar_event_form'),
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
            decoration: const InputDecoration(hintText: 'e.g. Team standup'),
            onChanged: widget.controller.setTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Date', style: AppTextStyles.kicker()),
          const SizedBox(height: 6),
          TextField(
            key: const Key('event_date_field'),
            readOnly: true,
            controller: TextEditingController(
              text: _dateFormat.format(form.date),
            ),
            onTap: _pickDate,
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            key: const Key('event_all_day_switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('All day'),
            value: form.isAllDay,
            onChanged: widget.controller.setAllDay,
          ),
          if (!form.isAllDay) ...[
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
                        readOnly: true,
                        controller: TextEditingController(
                          text: form.startTime.format(context),
                        ),
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
                        readOnly: true,
                        controller: TextEditingController(
                          text: form.endTime.format(context),
                        ),
                        onTap: () => _pickTime(start: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Location', style: AppTextStyles.kicker()),
          const SizedBox(height: 6),
          TextField(
            key: const Key('event_place_field'),
            controller: _location,
            decoration: const InputDecoration(hintText: 'Office, Google Meet…'),
            onChanged: widget.controller.setLocation,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Notes', style: AppTextStyles.kicker()),
          const SizedBox(height: 6),
          TextField(
            key: const Key('event_notes_field'),
            controller: _notes,
            decoration: const InputDecoration(hintText: 'Optional details'),
            onChanged: widget.controller.setNotes,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Reminder', style: AppTextStyles.kicker()),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            key: const Key('event_reminder_field'),
            initialValue: form.reminderMinutes,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(value: null, child: Text('None')),
              DropdownMenuItem(value: 15, child: Text('15 minutes before')),
              DropdownMenuItem(value: 30, child: Text('30 minutes before')),
              DropdownMenuItem(value: 60, child: Text('1 hour before')),
            ],
            onChanged: widget.controller.setReminderMinutes,
          ),
          if (form.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              form.errorMessage!,
              key: const Key('event_error'),
              style: AppTextStyles.bodySmall(color: AppColors.health),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          MemyPrimaryButton(
            key: const Key('event_save'),
            label: form.isSubmitting ? 'Saving…' : widget.saveLabel,
            onPressed: form.isSubmitting ? null : widget.onSave,
          ),
        ],
      ),
    );
  }
}
