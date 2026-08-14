import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/calendar_mutation_exception.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/services/calendar_event_validator.dart';
import '../providers/calendar_providers.dart';

class CalendarEventFormState {
  CalendarEventFormState({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.title = '',
    this.location = '',
    this.notes = '',
    this.isAllDay = false,
    this.reminderMinutes,
    this.isSubmitting = false,
    this.errorMessage,
    this.editing,
  });

  final String title;
  final String location;
  final String notes;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAllDay;
  final int? reminderMinutes;
  final bool isSubmitting;
  final String? errorMessage;

  /// The event being edited, or null when adding a new one. Retained so a
  /// save preserves external-link fields (provider/calendar/event id).
  final MemyCalendarEvent? editing;

  bool get isEditing => editing != null;

  CalendarEventFormState copyWith({
    String? title,
    String? location,
    String? notes,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAllDay,
    int? reminderMinutes,
    bool? isSubmitting,
    String? errorMessage,
    MemyCalendarEvent? editing,
    bool clearReminder = false,
    bool clearError = false,
  }) {
    return CalendarEventFormState(
      title: title ?? this.title,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderMinutes: clearReminder
          ? null
          : (reminderMinutes ?? this.reminderMinutes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      editing: editing ?? this.editing,
    );
  }
}

class CalendarEventFormController
    extends StateNotifier<CalendarEventFormState> {
  CalendarEventFormController(this._ref, {MemyCalendarEvent? existing})
    : super(_initialState(existing));

  final Ref _ref;

  static CalendarEventFormState _initialState(MemyCalendarEvent? existing) {
    if (existing == null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, now.hour + 1);
      return CalendarEventFormState(
        date: DateTime(start.year, start.month, start.day),
        startTime: TimeOfDay(hour: start.hour, minute: 0),
        endTime: TimeOfDay(hour: (start.hour + 1) % 24, minute: 0),
      );
    }
    final startLocal = existing.time.startUtc.toLocal();
    final endLocal = existing.time.endUtc.toLocal();
    return CalendarEventFormState(
      title: existing.title,
      location: existing.location ?? '',
      notes: existing.notes ?? '',
      date: DateTime(startLocal.year, startLocal.month, startLocal.day),
      startTime: TimeOfDay(hour: startLocal.hour, minute: startLocal.minute),
      endTime: TimeOfDay(hour: endLocal.hour, minute: endLocal.minute),
      isAllDay: existing.isAllDay,
      reminderMinutes: existing.reminderMinutes.isEmpty
          ? null
          : existing.reminderMinutes.first,
      editing: existing,
    );
  }

  /// Populate form from a freshly-loaded event (edit flow, once the async
  /// provider resolves).
  void hydrate(MemyCalendarEvent existing) {
    if (state.editing?.id == existing.id && state.title.isNotEmpty) return;
    state = _initialState(existing);
  }

  void setTitle(String value) =>
      state = state.copyWith(title: value, clearError: true);
  void setLocation(String value) => state = state.copyWith(location: value);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setDate(DateTime value) => state = state.copyWith(
    date: DateTime(value.year, value.month, value.day),
    clearError: true,
  );
  void setStartTime(TimeOfDay value) =>
      state = state.copyWith(startTime: value, clearError: true);
  void setEndTime(TimeOfDay value) =>
      state = state.copyWith(endTime: value, clearError: true);
  void setAllDay(bool value) =>
      state = state.copyWith(isAllDay: value, clearError: true);
  void setReminderMinutes(int? value) => state = value == null
      ? state.copyWith(clearReminder: true)
      : state.copyWith(reminderMinutes: value);

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Returns the saved event's id, or null on validation/submit failure.
  Future<String?> save() async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final existing = state.editing;
      if (existing != null && existing.origin == CalendarEventOrigin.external) {
        throw const CalendarMutationException(
          'Imported calendar events are read-only. Copy to MeMy to edit.',
        );
      }

      final title = CalendarEventValidator.validateTitle(state.title);
      final notes = CalendarEventValidator.validateNotes(state.notes);
      final location = CalendarEventValidator.validateLocation(state.location);
      final reminders = CalendarEventValidator.validateReminderMinutes(
        state.reminderMinutes == null ? const [] : [state.reminderMinutes!],
      );

      final CalendarEventTime time;
      if (state.isAllDay) {
        final start = LocalDate.fromDateTime(state.date);
        time = AllDayCalendarEventTime(
          startDate: start,
          endDateInclusive: start,
        );
      } else {
        final startLocal = _combine(state.date, state.startTime);
        var endLocal = _combine(state.date, state.endTime);
        if (!endLocal.isAfter(startLocal)) {
          endLocal = endLocal.add(const Duration(days: 1));
        }
        time = TimedCalendarEventTime(
          startUtc: startLocal.toUtc(),
          endUtc: endLocal.toUtc(),
        );
      }
      CalendarEventValidator.validateTimeRange(time);

      final repo = _ref.read(calendarRepositoryProvider);
      final now = _ref.read(appClockProvider).now().toUtc();

      final event = existing == null
          ? MemyCalendarEvent(
              id: _ref.read(uuidProvider).v4(),
              title: title,
              notes: notes,
              location: location,
              time: time,
              syncStatus: CalendarEventSyncStatus.pendingPush,
              reminderMinutes: reminders,
              createdAt: now,
              updatedAt: now,
            )
          : existing.copyWith(
              title: title,
              notes: notes,
              location: location,
              time: time,
              syncStatus: CalendarEventSyncStatus.pendingPush,
              reminderMinutes: reminders,
              updatedAt: now,
              clearNotes: notes == null,
              clearLocation: location == null,
            );

      final saved = existing == null
          ? await repo.createEvent(event)
          : await repo.updateEvent(event);

      state = state.copyWith(isSubmitting: false, editing: saved);

      // Push in the background — a slow/unavailable external calendar
      // should not block the user from leaving this screen.
      unawaited(_pushInBackground());

      return saved.id;
    } on CalendarEventValidationException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return null;
    } on CalendarMutationException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return null;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFacingErrorMessage(error),
      );
      return null;
    }
  }

  Future<void> _pushInBackground() async {
    try {
      await _ref.read(calendarSyncServiceProvider).push();
    } catch (_) {
      // Best-effort: the event is already saved locally as pendingPush and
      // will be retried on the next sync/refresh.
    }
  }
}

final addCalendarEventControllerProvider =
    StateNotifierProvider.autoDispose<
      CalendarEventFormController,
      CalendarEventFormState
    >((ref) => CalendarEventFormController(ref));

final editCalendarEventControllerProvider = StateNotifierProvider.autoDispose
    .family<CalendarEventFormController, CalendarEventFormState, String>((
      ref,
      eventId,
    ) {
      return CalendarEventFormController(ref);
    });
