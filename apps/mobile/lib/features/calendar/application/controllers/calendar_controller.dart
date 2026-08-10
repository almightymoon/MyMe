import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/application/providers/core_providers.dart';

/// View-only state for the month grid + selected day on
/// [CalendarOverviewScreen]. Event data itself is a live stream from
/// [calendarEventsInRangeProvider] — this controller never holds events.
class CalendarUiState {
  const CalendarUiState({
    required this.visibleMonth,
    required this.selectedDay,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;

  String get monthLabel => DateFormat('MMMM yyyy').format(visibleMonth);

  String selectedDayLabel(DateTime today) {
    final isToday =
        selectedDay.year == today.year &&
        selectedDay.month == today.month &&
        selectedDay.day == today.day;
    final dayPart = DateFormat('EEE, MMM dd').format(selectedDay);
    return isToday ? 'Today  ·  $dayPart' : dayPart;
  }

  CalendarUiState copyWith({DateTime? visibleMonth, DateTime? selectedDay}) {
    return CalendarUiState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class CalendarUiController extends Notifier<CalendarUiState> {
  @override
  CalendarUiState build() {
    final now = ref.watch(appClockProvider).now();
    return CalendarUiState(
      visibleMonth: DateTime(now.year, now.month),
      selectedDay: DateTime(now.year, now.month, now.day),
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

  DateTime _clampDay(DateTime selected, DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0).day;
    final day = selected.day.clamp(1, last);
    return DateTime(month.year, month.month, day);
  }
}

final calendarUiControllerProvider =
    NotifierProvider<CalendarUiController, CalendarUiState>(
      CalendarUiController.new,
    );
