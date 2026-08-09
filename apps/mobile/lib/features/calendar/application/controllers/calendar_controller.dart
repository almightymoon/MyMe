import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/seed/calendar_seed.dart';
import '../../domain/entities/schedule_item.dart';
import '../providers/calendar_providers.dart';

class CalendarState {
  const CalendarState({
    required this.visibleMonth,
    required this.selectedDay,
    required this.events,
    this.isSaving = false,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final List<ScheduleItem> events;
  final bool isSaving;

  String get monthLabel => DateFormat('MMMM yyyy').format(visibleMonth);

  String get selectedDayLabel {
    final now = CalendarSeed.demoDay;
    final isToday =
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;
    final dayPart = DateFormat('EEE, MMM dd').format(selectedDay);
    return isToday ? 'Today  ·  $dayPart' : dayPart;
  }

  List<ScheduleItem> get selectedEvents {
    final list = events.where((e) => e.isOnDay(selectedDay)).toList()
      ..sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    return list;
  }

  Set<int> eventDaysInVisibleMonth() {
    final days = <int>{};
    for (final e in events) {
      final d = e.date;
      if (d == null) continue;
      if (d.year == visibleMonth.year && d.month == visibleMonth.month) {
        days.add(d.day);
      }
    }
    return days;
  }

  CalendarState copyWith({
    DateTime? visibleMonth,
    DateTime? selectedDay,
    List<ScheduleItem>? events,
    bool? isSaving,
  }) {
    return CalendarState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final month = DateTime(
      CalendarSeed.demoDay.year,
      CalendarSeed.demoDay.month,
    );
    return CalendarState(
      visibleMonth: month,
      selectedDay: CalendarSeed.demoDay,
      events: List<ScheduleItem>.from(CalendarSeed.demoAgenda),
    );
  }

  void previousMonth() {
    final m = state.visibleMonth;
    final next = DateTime(m.year, m.month - 1);
    state = state.copyWith(
      visibleMonth: next,
      selectedDay: _clampDay(state.selectedDay, next),
    );
  }

  void nextMonth() {
    final m = state.visibleMonth;
    final next = DateTime(m.year, m.month + 1);
    state = state.copyWith(
      visibleMonth: next,
      selectedDay: _clampDay(state.selectedDay, next),
    );
  }

  void selectDay(DateTime day) {
    state = state.copyWith(
      selectedDay: DateTime(day.year, day.month, day.day),
      visibleMonth: DateTime(day.year, day.month),
    );
  }

  Future<String?> addEvent({
    required String title,
    required DateTime date,
    required String start,
    required String end,
    String? place,
    String? notes,
    int? reminderMinutes,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return 'Event title cannot be empty';

    state = state.copyWith(isSaving: true);
    try {
      final color =
          CalendarSeed.eventPalette[state.events.length %
              CalendarSeed.eventPalette.length];
      final event = ScheduleItem(
        id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
        title: trimmed,
        timeLabel: start.trim().isEmpty ? '10:00 AM' : start.trim(),
        endTimeLabel: end.trim().isEmpty ? '11:00 AM' : end.trim(),
        place: (place ?? '').trim().isEmpty ? 'Anywhere' : place!.trim(),
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        date: DateTime(date.year, date.month, date.day),
        colorValue: color,
        reminderMinutes: reminderMinutes,
      );

      // Keep repository in sync for other surfaces that read it.
      await ref.read(calendarRepositoryProvider).addEvent(event);

      state = state.copyWith(
        isSaving: false,
        events: [...state.events, event],
        selectedDay: event.date!,
        visibleMonth: DateTime(event.date!.year, event.date!.month),
      );
      return null;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return e.toString();
    }
  }

  DateTime _clampDay(DateTime selected, DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0).day;
    final day = selected.day.clamp(1, last);
    return DateTime(month.year, month.month, day);
  }
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);
