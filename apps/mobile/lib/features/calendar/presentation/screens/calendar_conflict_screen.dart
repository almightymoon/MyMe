import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../../domain/entities/calendar_sync_conflict.dart';
import '../../domain/entities/conflict_resolution.dart';

class CalendarConflictScreen extends ConsumerStatefulWidget {
  const CalendarConflictScreen({super.key});

  @override
  ConsumerState<CalendarConflictScreen> createState() =>
      _CalendarConflictScreenState();
}

class _CalendarConflictScreenState
    extends ConsumerState<CalendarConflictScreen> {
  final Set<String> _resolving = {};

  Future<void> _resolve(
    String conflictId,
    ConflictResolution resolution,
  ) async {
    setState(() => _resolving.add(conflictId));
    try {
      await ref
          .read(calendarSyncServiceProvider)
          .resolveConflict(conflictId: conflictId, resolution: resolution);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _resolving.remove(conflictId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final conflicts =
        ref.watch(calendarConflictsProvider).valueOrNull ?? const [];

    return Scaffold(
      key: const Key('calendar_conflicts'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Sync Conflicts',
              subtitle: conflicts.isEmpty
                  ? 'All caught up'
                  : '${conflicts.length} event(s) changed on both sides',
              leading: IconButton(
                key: const Key('calendar_conflicts_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.calendar),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: conflicts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: Center(
                        child: Text(
                          'No sync conflicts right now.',
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxxl,
                      ),
                      children: [
                        for (final conflict in conflicts)
                          _ConflictCard(
                            key: Key('conflict_${conflict.id}'),
                            conflict: conflict,
                            busy: _resolving.contains(conflict.id),
                            onResolve: (resolution) =>
                                _resolve(conflict.id, resolution),
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

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    super.key,
    required this.conflict,
    required this.busy,
    required this.onResolve,
  });

  final CalendarSyncConflict conflict;
  final bool busy;
  final ValueChanged<ConflictResolution> onResolve;

  String _describe(String title, DateTime startUtc) {
    return '$title · ${DateFormat.yMMMd().add_jm().format(startUtc.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Conflicting event'),
          Text(
            'Yours: ${_describe(conflict.localSnapshot.title, conflict.localSnapshot.time.startUtc)}',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: 4),
          Text(
            'Device: ${_describe(conflict.externalSnapshot.title, conflict.externalSnapshot.time.startUtc)}',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: Key('conflict_keep_local_${conflict.id}'),
                  onPressed: busy
                      ? null
                      : () => onResolve(ConflictResolution.keepLocal),
                  child: const Text('Keep mine'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: Key('conflict_keep_external_${conflict.id}'),
                  onPressed: busy
                      ? null
                      : () => onResolve(ConflictResolution.keepExternal),
                  child: const Text('Keep device'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: Key('conflict_keep_both_${conflict.id}'),
              onPressed: busy
                  ? null
                  : () => onResolve(ConflictResolution.keepBoth),
              child: Text(busy ? 'Resolving…' : 'Keep both'),
            ),
          ),
        ],
      ),
    );
  }
}
