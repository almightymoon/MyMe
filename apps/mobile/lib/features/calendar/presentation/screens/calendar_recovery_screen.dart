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
import '../../../../core/widgets/section_header.dart';
import '../../application/providers/calendar_providers.dart';
import '../../domain/entities/calendar_create_recovery_case.dart';

class CalendarRecoveryScreen extends ConsumerStatefulWidget {
  const CalendarRecoveryScreen({super.key});

  @override
  ConsumerState<CalendarRecoveryScreen> createState() =>
      _CalendarRecoveryScreenState();
}

class _CalendarRecoveryScreenState
    extends ConsumerState<CalendarRecoveryScreen> {
  final Set<String> _busy = {};
  final Set<String> _expanded = {};

  Future<void> _run(
    String recoveryCaseId,
    Future<void> Function() action,
  ) async {
    setState(() => _busy.add(recoveryCaseId));
    try {
      await action();
      ref.invalidate(calendarRecoveryCasesProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _busy.remove(recoveryCaseId));
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    required Key confirmKey,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: confirmKey,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  String _typeLabel(CalendarCreateRecoveryType type) {
    switch (type) {
      case CalendarCreateRecoveryType.noMatchUnknownOutcome:
        return 'No match on device';
      case CalendarCreateRecoveryType.multipleMarkerMatches:
        return 'Multiple device matches';
    }
  }

  String _shortEventId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 8)}…';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(calendarRecoveryCasesProvider);
    final cases = async.valueOrNull ?? const <CalendarCreateRecoveryCase>[];

    return Scaffold(
      key: const Key('calendar_recovery'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Create recovery',
              subtitle: cases.isEmpty
                  ? 'All caught up'
                  : '${cases.length} create(s) need your review',
              leading: IconButton(
                key: const Key('calendar_recovery_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.calendar),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Center(
                    child: Text(
                      'Could not load recovery cases.',
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: Center(
                        child: Text(
                          'No create-recovery cases right now.',
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    children: [
                      for (final recoveryCase in items)
                        _RecoveryCard(
                          key: Key('recovery_case_${recoveryCase.id}'),
                          recoveryCase: recoveryCase,
                          typeLabel: _typeLabel(recoveryCase.recoveryType),
                          shortEventId: _shortEventId(recoveryCase.memyEventId),
                          expanded: _expanded.contains(recoveryCase.id),
                          busy: _busy.contains(recoveryCase.id),
                          onToggleExpand: () {
                            setState(() {
                              if (_expanded.contains(recoveryCase.id)) {
                                _expanded.remove(recoveryCase.id);
                              } else {
                                _expanded.add(recoveryCase.id);
                              }
                            });
                          },
                          onOpenEvent: () => context.push(
                            RoutePaths.eventDetailPath(
                              recoveryCase.memyEventId,
                            ),
                          ),
                          onSearchAgain: () => _run(
                            recoveryCase.id,
                            () => ref
                                .read(calendarSyncServiceProvider)
                                .searchAgainCreateRecovery(recoveryCase.id),
                          ),
                          onLinkCandidate: (candidate) => _run(
                            recoveryCase.id,
                            () => ref
                                .read(calendarSyncServiceProvider)
                                .linkCreateRecoveryCandidate(
                                  recoveryCaseId: recoveryCase.id,
                                  externalEventId: candidate.externalEventId,
                                  externalCalendarId:
                                      candidate.externalCalendarId,
                                ),
                          ),
                          onKeepLocalOnly: () async {
                            final ok = await _confirm(
                              title: 'Keep local only?',
                              body:
                                  'This MeMy event will stay on your device '
                                  'without linking to the phone calendar.',
                              confirmLabel: 'Keep local only',
                              confirmKey: Key(
                                'recovery_confirm_local_${recoveryCase.id}',
                              ),
                            );
                            if (!ok) return;
                            await _run(
                              recoveryCase.id,
                              () => ref
                                  .read(calendarSyncServiceProvider)
                                  .keepCreateRecoveryLocalOnly(recoveryCase.id),
                            );
                          },
                          onRetryCreate: () async {
                            final ok = await _confirm(
                              title: 'Retry create?',
                              body:
                                  'MeMy will try creating the device calendar '
                                  'event again on the next sync.',
                              confirmLabel: 'Retry create',
                              confirmKey: Key(
                                'recovery_confirm_retry_${recoveryCase.id}',
                              ),
                            );
                            if (!ok) return;
                            await _run(
                              recoveryCase.id,
                              () => ref
                                  .read(calendarSyncServiceProvider)
                                  .retryCreateAfterConfirmation(
                                    recoveryCase.id,
                                  ),
                            );
                          },
                          onDismiss: () async {
                            final ok = await _confirm(
                              title: 'Dismiss recovery?',
                              body:
                                  'This hides the recovery case. The sync '
                                  'operation may still need attention later.',
                              confirmLabel: 'Dismiss',
                              confirmKey: Key(
                                'recovery_confirm_dismiss_${recoveryCase.id}',
                              ),
                            );
                            if (!ok) return;
                            await _run(
                              recoveryCase.id,
                              () => ref
                                  .read(calendarSyncServiceProvider)
                                  .dismissCreateRecovery(recoveryCase.id),
                            );
                          },
                          onRemoveEvent: () async {
                            final ok = await _confirm(
                              title: 'Remove MeMy event?',
                              body:
                                  'Deletes this MeMy-owned event and closes '
                                  'the recovery case. This cannot be undone.',
                              confirmLabel: 'Remove event',
                              confirmKey: Key(
                                'recovery_confirm_remove_${recoveryCase.id}',
                              ),
                            );
                            if (!ok) return;
                            await _run(
                              recoveryCase.id,
                              () => ref
                                  .read(calendarSyncServiceProvider)
                                  .removeMeMyEventForRecovery(recoveryCase.id),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({
    super.key,
    required this.recoveryCase,
    required this.typeLabel,
    required this.shortEventId,
    required this.expanded,
    required this.busy,
    required this.onToggleExpand,
    required this.onOpenEvent,
    required this.onSearchAgain,
    required this.onLinkCandidate,
    required this.onKeepLocalOnly,
    required this.onRetryCreate,
    required this.onDismiss,
    required this.onRemoveEvent,
  });

  final CalendarCreateRecoveryCase recoveryCase;
  final String typeLabel;
  final String shortEventId;
  final bool expanded;
  final bool busy;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenEvent;
  final VoidCallback onSearchAgain;
  final ValueChanged<CalendarCreateRecoveryCandidate> onLinkCandidate;
  final VoidCallback onKeepLocalOnly;
  final VoidCallback onRetryCreate;
  final VoidCallback onDismiss;
  final VoidCallback onRemoveEvent;

  @override
  Widget build(BuildContext context) {
    final isNoMatch =
        recoveryCase.recoveryType ==
        CalendarCreateRecoveryType.noMatchUnknownOutcome;
    final isMulti =
        recoveryCase.recoveryType ==
        CalendarCreateRecoveryType.multipleMarkerMatches;

    return MemyCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionHeader(title: typeLabel)),
              IconButton(
                key: Key('recovery_expand_${recoveryCase.id}'),
                tooltip: expanded ? 'Collapse' : 'Expand',
                onPressed: onToggleExpand,
                icon: Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
              ),
            ],
          ),
          Text(
            'Candidates: ${recoveryCase.candidates.length}',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: 4),
          InkWell(
            key: Key('recovery_event_link_${recoveryCase.id}'),
            onTap: onOpenEvent,
            child: Text(
              'Event · $shortEventId',
              style: AppTextStyles.bodyMedium().copyWith(
                color: AppColors.ember,
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: AppSpacing.md),
            if (isMulti) ...[
              Text(
                'Choose a device match to link (IDs only):',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final candidate in recoveryCase.candidates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: Key(
                        'recovery_link_${recoveryCase.id}_${candidate.externalEventId}',
                      ),
                      onPressed: busy ? null : () => onLinkCandidate(candidate),
                      child: Text(
                        'Link · ${candidate.externalEventId.length > 14 ? '${candidate.externalEventId.substring(0, 12)}…' : candidate.externalEventId}',
                      ),
                    ),
                  ),
                ),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: Key('recovery_search_again_${recoveryCase.id}'),
                onPressed: busy ? null : onSearchAgain,
                child: const Text('Search again'),
              ),
            ),
            const SizedBox(height: 8),
            if (isNoMatch) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: Key('recovery_retry_${recoveryCase.id}'),
                  onPressed: busy ? null : onRetryCreate,
                  child: const Text('Retry create'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: Key('recovery_keep_local_${recoveryCase.id}'),
                onPressed: busy ? null : onKeepLocalOnly,
                child: const Text('Keep local only'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: Key('recovery_dismiss_${recoveryCase.id}'),
                    onPressed: busy ? null : onDismiss,
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    key: Key('recovery_remove_${recoveryCase.id}'),
                    onPressed: busy ? null : onRemoveEvent,
                    child: Text(busy ? 'Working…' : 'Remove event'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
