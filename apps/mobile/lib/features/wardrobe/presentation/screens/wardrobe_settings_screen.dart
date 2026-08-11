import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_enums.dart';

class WardrobeSettingsScreen extends ConsumerStatefulWidget {
  const WardrobeSettingsScreen({super.key});

  @override
  ConsumerState<WardrobeSettingsScreen> createState() =>
      _WardrobeSettingsScreenState();
}

class _WardrobeSettingsScreenState
    extends ConsumerState<WardrobeSettingsScreen> {
  var _busy = false;
  String? _usageLabel;
  String? _message;

  @override
  void initState() {
    super.initState();
    _refreshUsage();
  }

  Future<void> _refreshUsage() async {
    final bytes = await ref
        .read(wardrobeImageStoreProvider)
        .calculateStorageUsage();
    if (!mounted) return;
    setState(() => _usageLabel = _formatBytes(bytes));
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B on this device';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB on this device';
    return '${(kb / 1024).toStringAsFixed(1)} MB on this device';
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final settings = ref.watch(wardrobeUserPreferencesProvider);
    return MemyModuleScaffold(
      key: const Key('wardrobe_settings'),
      title: 'Wardrobe settings',
      fallbackPath: RoutePaths.settings,
      showBottomNav: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Local image storage: ${_usageLabel ?? '…'}'),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show purchase information'),
            value: settings.showPurchaseInformation,
            onChanged: (value) async {
              await prefs.setBool('memy_wardrobe_show_purchase', value);
              ref.invalidate(wardrobeUserPreferencesProvider);
            },
          ),
          DropdownButtonFormField<int>(
            // ignore: deprecated_member_use
            value: settings.avoidRecentlyWornDays,
            decoration: const InputDecoration(
              labelText: 'Avoid recently worn items (days)',
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Off')),
              DropdownMenuItem(value: 3, child: Text('3 days')),
              DropdownMenuItem(value: 7, child: Text('7 days')),
              DropdownMenuItem(value: 14, child: Text('14 days')),
            ],
            onChanged: (value) async {
              if (value == null) return;
              await prefs.setInt('memy_wardrobe_avoid_recent_days', value);
              ref.invalidate(wardrobeUserPreferencesProvider);
            },
          ),
          DropdownButtonFormField<DressCode?>(
            // ignore: deprecated_member_use
            value: settings.defaultDressCode,
            decoration: const InputDecoration(labelText: 'Default dress code'),
            items: [
              const DropdownMenuItem<DressCode?>(
                value: null,
                child: Text('None'),
              ),
              for (final value in DressCode.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) async {
              if (value == null) {
                await prefs.remove('memy_wardrobe_default_dress_code');
              } else {
                await prefs.setString(
                  'memy_wardrobe_default_dress_code',
                  value.name,
                );
              }
              ref.invalidate(wardrobeUserPreferencesProvider);
            },
          ),
          DropdownButtonFormField<ClimateTag?>(
            // ignore: deprecated_member_use
            value: settings.defaultClimateTag,
            decoration: const InputDecoration(
              labelText: 'Default climate tag (manual)',
            ),
            items: [
              const DropdownMenuItem<ClimateTag?>(
                value: null,
                child: Text('None'),
              ),
              for (final value in ClimateTag.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) async {
              if (value == null) {
                await prefs.remove('memy_wardrobe_default_climate');
              } else {
                await prefs.setString(
                  'memy_wardrobe_default_climate',
                  value.name,
                );
              }
              ref.invalidate(wardrobeUserPreferencesProvider);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Suggestions stay on this device. They are not based on live weather or AI.',
          ),
          if (_message != null) ...[const SizedBox(height: 8), Text(_message!)],
          const SizedBox(height: 16),
          MemyPrimaryButton(
            key: const Key('wardrobe_clean_orphans'),
            label: _busy ? 'Cleaning…' : 'Clean unused photos',
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      final items = await ref
                          .read(wardrobeRepositoryProvider)
                          .getItems();
                      final known = <String>{};
                      for (final item in items) {
                        final image = item.imageReference;
                        if (image == null) continue;
                        known
                          ..add(image.relativeOriginalPath)
                          ..add(image.relativeThumbnailPath);
                      }
                      final cleaned = await ref
                          .read(wardrobeImageStoreProvider)
                          .cleanOrphanImages(known);
                      await _refreshUsage();
                      if (!mounted) return;
                      setState(() {
                        _busy = false;
                        _message = cleaned == 0
                            ? 'No unused photos found.'
                            : 'Removed $cleaned unused photo files.';
                      });
                    } catch (error) {
                      if (!mounted) return;
                      setState(() {
                        _busy = false;
                        _message = userFacingErrorMessage(error);
                      });
                    }
                  },
          ),
        ],
      ),
    );
  }
}
