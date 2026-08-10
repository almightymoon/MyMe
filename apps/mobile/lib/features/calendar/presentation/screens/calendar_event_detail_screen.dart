import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/providers/calendar_providers.dart';
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/memy_calendar_event.dart';

class CalendarEventDetailScreen extends ConsumerStatefulWidget {
  const CalendarEventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<CalendarEventDetailScreen> createState() =>
      _CalendarEventDetailScreenState();
}

class _CalendarEventDetailScreenState
    extends ConsumerState<CalendarEventDetailScreen> {
  var _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(MemyCalendarEvent event) async {
    if (event.origin == CalendarEventOrigin.external) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Imported events can’t be deleted in MeMy. Copy to MeMy first.',
          ),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('“${event.title}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_event'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      final repo = ref.read(calendarRepositoryProvider);
      if (event.isLinkedToExternal) {
        await repo.updateEvent(
          event.copyWith(syncStatus: CalendarEventSyncStatus.pendingDelete),
        );
        unawaited(ref.read(calendarSyncServiceProvider).push());
      } else {
        await repo.deleteEvent(event.id);
      }
      if (mounted) context.go(RoutePaths.calendar);
    });
  }

  Future<void> _copyToMeMy(MemyCalendarEvent event) async {
    await _run(() async {
      final copy = await ref
          .read(calendarRepositoryProvider)
          .copyExternalAsLocal(event);
      unawaited(ref.read(calendarSyncServiceProvider).push());
      if (!mounted) return;
      context.push(RoutePaths.editEventPath(copy.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(calendarEventByIdProvider(widget.eventId));

    return Scaffold(
      key: const Key('calendar_event_detail'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: eventAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: LoadingCardSkeleton(height: 160, lines: 4),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: InlineErrorCard(
              message: userFacingErrorMessage(error),
              onRetry: () =>
                  ref.invalidate(calendarEventByIdProvider(widget.eventId)),
            ),
          ),
          data: (event) {
            if (event == null) {
              return Column(
                children: [
                  MemyPageHeader(
                    title: 'Event',
                    leading: IconButton(
                      onPressed: () =>
                          memyBack(context, fallback: RoutePaths.calendar),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.page),
                    child: Text('This event was deleted or is unavailable.'),
                  ),
                ],
              );
            }

            final isExternal = event.origin == CalendarEventOrigin.external;

            return Column(
              children: [
                MemyPageHeader(
                  title: event.title,
                  subtitle: isExternal
                      ? 'Imported · read-only'
                      : event.isLinkedToExternal
                      ? 'Synced with device calendar'
                      : 'MeMy event',
                  leading: IconButton(
                    key: const Key('event_detail_back'),
                    tooltip: 'Back',
                    onPressed: () =>
                        memyBack(context, fallback: RoutePaths.calendar),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  trailing: PopupMenuButton<String>(
                    key: const Key('event_detail_menu'),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push(RoutePaths.editEventPath(event.id));
                        return;
                      }
                      if (value == 'copy') {
                        await _copyToMeMy(event);
                        return;
                      }
                      if (value == 'delete') {
                        await _confirmDelete(event);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isExternal)
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (isExternal)
                        const PopupMenuItem(
                          value: 'copy',
                          child: Text('Copy to MeMy'),
                        ),
                      if (!isExternal)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
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
                      if (isExternal) ...[
                        MemyCard(
                          key: const Key('event_readonly_banner'),
                          child: Text(
                            'This event was imported from your device calendar '
                            'and can’t be edited here. Copy it to MeMy to make '
                            'changes that sync back.',
                            style: AppTextStyles.bodyMedium(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MemyCard(
                          child: ListTile(
                            key: const Key('event_copy_to_memy'),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Copy to MeMy',
                              style: AppTextStyles.titleMedium(),
                            ),
                            subtitle: Text(
                              'Creates an editable MeMy copy',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.faintText,
                              ),
                            ),
                            trailing: const Icon(Icons.copy_rounded),
                            onTap: _busy ? null : () => _copyToMeMy(event),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      MemyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'When'),
                            Text(
                              event.isAllDay
                                  ? '${DateFormat.yMMMd().format(event.time.startUtc.toLocal())} · All day'
                                  : '${DateFormat.yMMMd().add_jm().format(event.time.startUtc.toLocal())} '
                                        '– ${DateFormat.jm().format(event.time.endUtc.toLocal())}',
                              style: AppTextStyles.bodyMedium(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (event.location?.trim().isNotEmpty == true) ...[
                        MemyCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Location'),
                              Text(
                                event.location!,
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (event.notes?.trim().isNotEmpty == true) ...[
                        MemyCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Notes'),
                              Text(
                                event.notes!,
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      MemyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Sync status'),
                            Text(
                              _syncStatusLabel(event.syncStatus),
                              style: AppTextStyles.bodyMedium(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _syncStatusLabel(CalendarEventSyncStatus status) {
    switch (status) {
      case CalendarEventSyncStatus.localOnly:
        return 'MeMy only';
      case CalendarEventSyncStatus.pendingPush:
        return 'Waiting to sync to your calendar';
      case CalendarEventSyncStatus.synced:
        return 'Synced';
      case CalendarEventSyncStatus.pendingDelete:
        return 'Waiting to be removed from your calendar';
      case CalendarEventSyncStatus.conflict:
        return 'Sync conflict — needs your review';
      case CalendarEventSyncStatus.externallyMissing:
        return 'Missing from device calendar';
      case CalendarEventSyncStatus.hidden:
        return 'Hidden (removed from device)';
    }
  }
}
