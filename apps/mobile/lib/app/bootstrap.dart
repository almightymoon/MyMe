import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import '../core/application/providers/core_providers.dart';
import '../core/config/environment_config.dart';
import '../features/calendar/application/providers/calendar_providers.dart';
import '../features/trust/application/providers/trust_providers.dart';

Future<Widget> bootstrap() async {
  EnvironmentConfig.validate();
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const _BootstrapHost(child: MemyApp()),
  );
}

/// Ensures calendar connection state is hydrated once providers exist.
class _BootstrapHost extends ConsumerStatefulWidget {
  const _BootstrapHost({required this.child});

  final Widget child;

  @override
  ConsumerState<_BootstrapHost> createState() => _BootstrapHostState();
}

class _BootstrapHostState extends ConsumerState<_BootstrapHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fire-and-forget; UI reads registry reactively.
      ref.read(calendarBootstrapProvider);
      // Best-effort stale export temp cleanup.
      ref.read(exportTempCleanupProvider);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
