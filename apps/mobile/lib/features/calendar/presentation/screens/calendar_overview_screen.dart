import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/controllers/calendar_controller.dart';
import '../../application/providers/calendar_providers.dart';
import '../../data/mappers/schedule_item_mapper.dart';
import '../../domain/entities/schedule_item.dart';

class CalendarOverviewScreen extends ConsumerWidget {
  const CalendarOverviewScreen({super.key});

  static const _dows = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cal = ref.watch(calendarUiControllerProvider);
    final controller = ref.read(calendarUiControllerProvider.notifier);
    final today = DateTime.now();

    final monthStart = DateTime.utc(
      cal.visibleMonth.year,
      cal.visibleMonth.month,
    );
    final monthEnd = DateTime.utc(
      cal.visibleMonth.year,
      cal.visibleMonth.month + 1,
    );
    final eventsAsync = ref.watch(
      calendarEventsInRangeProvider(
        CalendarDateRange(startUtc: monthStart, endUtc: monthEnd),
      ),
    );
    final conflicts =
        ref.watch(calendarConflictsProvider).valueOrNull ?? const [];
    final recoveryCases =
        ref.watch(calendarRecoveryCasesProvider).valueOrNull ?? const [];

    return MemyModuleScaffold(
      key: const Key('calendar_overview'),
      title: 'Calendar',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MemyIconPlain(
            key: const Key('calendar_sync'),
            icon: Icons.sync_rounded,
            onPressed: () =>
                ref.read(calendarSyncServiceProvider).manualRefresh(),
          ),
          MemyIconPlain(
            key: const Key('calendar_add'),
            icon: Icons.add_rounded,
            onPressed: () => context.push(RoutePaths.addEvent),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ConnectionBanner(),
          if (conflicts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ConflictBanner(count: conflicts.length),
          ],
          if (recoveryCases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _RecoveryBanner(count: recoveryCases.length),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(cal.monthLabel, style: AppTextStyles.titleMedium()),
              ),
              IconButton(
                key: const Key('calendar_prev_month'),
                tooltip: 'Previous month',
                onPressed: controller.previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                key: const Key('calendar_next_month'),
                tooltip: 'Next month',
                onPressed: controller.nextMonth,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.faintText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          eventsAsync.when(
            loading: () => const LoadingCardSkeleton(height: 260, lines: 1),
            error: (error, _) => InlineErrorCard(
              message: userFacingErrorMessage(error),
              onRetry: () => ref.invalidate(
                calendarEventsInRangeProvider(
                  CalendarDateRange(startUtc: monthStart, endUtc: monthEnd),
                ),
              ),
            ),
            data: (events) {
              final schedule = ScheduleItemMapper.fromMemyEvents(events);
              final eventDays = <int>{
                for (final e in schedule)
                  if (e.date != null &&
                      e.date!.year == cal.visibleMonth.year &&
                      e.date!.month == cal.visibleMonth.month)
                    e.date!.day,
              };
              final cells = _buildCells(cal.visibleMonth);
              final agenda =
                  schedule.where((e) => e.isOnDay(cal.selectedDay)).toList()
                    ..sort((a, b) => a.timeLabel.compareTo(b.timeLabel));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MemyCard(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            for (final d in _dows)
                              Expanded(
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.faintText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (var row = 0; row < 6; row++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                for (var col = 0; col < 7; col++)
                                  Expanded(
                                    child: _DayCell(
                                      day: cells[row * 7 + col],
                                      selectedDay: cal.selectedDay.day,
                                      selectedMonth: cal.selectedDay.month,
                                      selectedYear: cal.selectedDay.year,
                                      visibleMonth: cal.visibleMonth,
                                      today: today,
                                      hasEvent:
                                          cells[row * 7 + col] != null &&
                                          eventDays.contains(
                                            cells[row * 7 + col],
                                          ),
                                      onTap: (day) => controller.selectDay(
                                        DateTime(
                                          cal.visibleMonth.year,
                                          cal.visibleMonth.month,
                                          day,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cal.selectedDayLabel(today),
                          style: AppTextStyles.bodySmall().copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.faintText,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key('calendar_add_for_day'),
                        onPressed: () => context.push(RoutePaths.addEvent),
                        child: Text(
                          'Add',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.ember,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (agenda.isEmpty)
                    MemyCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Text(
                            'No events',
                            style: AppTextStyles.titleMedium().copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to schedule something for this day.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall(
                              color: AppColors.faintText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (var i = 0; i < agenda.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _AgendaRow(item: agenda[i]),
                    ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Sunday-first month grid (prototype `#cal-grid`).
  static List<int?> _buildCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday % 7; // DateTime: Mon=1…Sun=7 → Sun=0
    final cells = List<int?>.filled(42, null);
    for (var d = 1; d <= daysInMonth; d++) {
      cells[lead + d - 1] = d;
    }
    return cells;
  }
}

class _ConnectionBanner extends ConsumerWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(calendarConnectionProvider);
    if (connection.status == IntegrationConnectionStatus.connected ||
        connection.status == IntegrationConnectionStatus.syncing) {
      return const SizedBox.shrink();
    }

    final isDegraded = connection.status.isDegraded;
    final isStale =
        connection.status == IntegrationConnectionStatus.staleCacheAvailable;
    final label = switch (connection.status) {
      IntegrationConnectionStatus.partiallyConnected =>
        'Calendar is partially connected — pick a writable calendar to push events.',
      IntegrationConnectionStatus.staleCacheAvailable =>
        'Showing cached calendar. Live device calendar is temporarily unavailable.',
      IntegrationConnectionStatus.providerUnavailable =>
        'Device calendar is unavailable on this device.',
      IntegrationConnectionStatus.permissionStatusUnknown ||
      IntegrationConnectionStatus.error => 'Calendar sync needs attention.',
      IntegrationConnectionStatus.configurationInvalid =>
        'Calendar connection needs reconfiguration.',
      _ => 'Connect a device calendar to see it here too.',
    };

    return MemyCard(
      key: const Key('calendar_connection_banner'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            isStale
                ? Icons.cloud_off_outlined
                : isDegraded
                ? Icons.error_outline_rounded
                : Icons.link_rounded,
            color: isDegraded ? AppColors.health : AppColors.ember,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.bodySmall())),
          TextButton(
            key: const Key('calendar_connect_cta'),
            onPressed: () => context.push(RoutePaths.calendarConnect),
            child: Text(
              isDegraded ? 'Fix' : 'Connect',
              style: AppTextStyles.labelMedium(color: AppColors.ember),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictBanner extends StatelessWidget {
  const _ConflictBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('calendar_conflict_banner'),
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(RoutePaths.calendarConflicts),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.health),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              count == 1
                  ? '1 sync conflict needs your review'
                  : '$count sync conflicts need your review',
              style: AppTextStyles.bodySmall(),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.faintText),
        ],
      ),
    );
  }
}

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('calendar_recovery_banner'),
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(RoutePaths.calendarRecovery),
      child: Row(
        children: [
          Icon(Icons.healing_rounded, color: AppColors.health),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              count == 1
                  ? '1 create recovery needs your review'
                  : '$count create recoveries need your review',
              style: AppTextStyles.bodySmall(),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.faintText),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.visibleMonth,
    required this.today,
    required this.hasEvent,
    required this.onTap,
  });

  final int? day;
  final int selectedDay;
  final int selectedMonth;
  final int selectedYear;
  final DateTime visibleMonth;
  final DateTime today;
  final bool hasEvent;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox(height: 38);

    final isSelected =
        day == selectedDay &&
        visibleMonth.month == selectedMonth &&
        visibleMonth.year == selectedYear;
    final isToday =
        day == today.day &&
        visibleMonth.month == today.month &&
        visibleMonth.year == today.year;

    return InkWell(
      key: Key('cal_day_$day'),
      customBorder: const CircleBorder(),
      onTap: () => onTap(day!),
      child: SizedBox(
        height: 38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.ember : Colors.transparent,
                border: !isSelected && isToday
                    ? Border.all(color: AppColors.ember.withValues(alpha: 0.35))
                    : null,
              ),
              child: Text(
                '$day',
                style: AppTextStyles.bodySmall().copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryText,
                ),
              ),
            ),
            if (hasEvent && !isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: Key('agenda_${item.id}'),
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(RoutePaths.eventDetailPath(item.id)),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.timeLabel,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ember,
                  ),
                ),
                if (item.endTimeLabel != null)
                  Text(
                    item.endTimeLabel!,
                    style: AppTextStyles.labelSmall(color: AppColors.faintText),
                  ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 36,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Color(item.colorValue),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                ),
                if (item.metaLabel.isNotEmpty)
                  Text(
                    item.metaLabel,
                    style: AppTextStyles.bodySmall(color: AppColors.faintText),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
