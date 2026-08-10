import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/trust_providers.dart';
import '../../domain/entities/data_catalog.dart';
import '../../domain/entities/export_request.dart';
import '../widgets/trust_screen_scaffold.dart';

class PrivacyExportScreen extends ConsumerStatefulWidget {
  const PrivacyExportScreen({super.key});

  @override
  ConsumerState<PrivacyExportScreen> createState() =>
      _PrivacyExportScreenState();
}

class _PrivacyExportScreenState extends ConsumerState<PrivacyExportScreen> {
  final Set<DataModule> _selected = {
    DataModule.goals,
    DataModule.finance,
    DataModule.habits,
    DataModule.calendar,
    DataModule.health,
    DataModule.preferences,
  };
  bool _includeMeMyEvents = false;
  bool _busy = false;
  String? _lastPath;

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('privacy_export'),
      title: 'Export data',
      subtitle: 'Creates a JSON file on this device',
      fallbackPath: RoutePaths.privacy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Raw health sample values and external calendar content are '
            'excluded by default. Secrets are never included.',
            style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._selectableModules.map((module) {
            return CheckboxListTile(
              key: Key('export_module_${module.name}'),
              value: _selected.contains(module),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selected.add(module);
                  } else {
                    _selected.remove(module);
                  }
                });
              },
              title: Text(_label(module)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          }),
          SwitchListTile(
            key: const Key('export_include_memy_events'),
            value: _includeMeMyEvents,
            onChanged: (v) => setState(() => _includeMeMyEvents = v),
            title: const Text('Include MeMy-owned calendar events'),
            subtitle: const Text('Still excludes external device events'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            key: const Key('export_run'),
            label: _busy ? 'Exporting…' : 'Export JSON',
            onPressed: _busy || _selected.isEmpty ? null : _runExport,
          ),
          if (_lastPath != null) ...[
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              child: Text(
                'Saved to:\n$_lastPath',
                style: AppTextStyles.bodySmall(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _selectableModules = [
    DataModule.goals,
    DataModule.finance,
    DataModule.habits,
    DataModule.calendar,
    DataModule.health,
    DataModule.preferences,
  ];

  String _label(DataModule module) => switch (module) {
    DataModule.goals => 'Goals',
    DataModule.finance => 'Finance',
    DataModule.habits => 'Habits',
    DataModule.calendar => 'Calendar (config / optional MeMy events)',
    DataModule.health => 'Health connection summary',
    DataModule.preferences => 'Preferences',
    _ => module.name,
  };

  Future<void> _runExport() async {
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(localDataExportServiceProvider)
          .export(
            ExportRequest(
              modules: Set<DataModule>.from(_selected),
              includeMeMyOwnedCalendarEvents: _includeMeMyEvents,
            ),
          );
      setState(() => _lastPath = result.filePath);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(result.filePath)], text: 'MeMy data export'),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
