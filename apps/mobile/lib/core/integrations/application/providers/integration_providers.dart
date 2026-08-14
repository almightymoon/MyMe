import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/integration_connection.dart';
import '../../domain/integration_provider.dart';

/// Runtime registry of every integration's connection state.
///
/// This is process-local UI state (spinners, banners, last-sync labels).
/// Durable facts (which calendars are selected, last sync anchors) live in
/// each feature's own persistence — e.g. Calendar's `calendar_config` table.
class IntegrationConnectionRegistry
    extends Notifier<Map<IntegrationProvider, IntegrationConnection>> {
  @override
  Map<IntegrationProvider, IntegrationConnection> build() => {
    for (final provider in IntegrationProvider.values)
      provider: IntegrationConnection.initial(provider),
  };

  IntegrationConnection get(IntegrationProvider provider) {
    return state[provider] ?? IntegrationConnection.initial(provider);
  }

  void set(IntegrationConnection connection) {
    state = {...state, connection.provider: connection};
  }

  void updateConnection(
    IntegrationProvider provider,
    IntegrationConnection Function(IntegrationConnection current) updater,
  ) {
    set(updater(get(provider)));
  }
}

final integrationConnectionRegistryProvider =
    NotifierProvider<
      IntegrationConnectionRegistry,
      Map<IntegrationProvider, IntegrationConnection>
    >(IntegrationConnectionRegistry.new);

final calendarConnectionProvider = Provider.autoDispose<IntegrationConnection>((
  ref,
) {
  final all = ref.watch(integrationConnectionRegistryProvider);
  return all[IntegrationProvider.calendar] ??
      IntegrationConnection.initial(IntegrationProvider.calendar);
});

final healthConnectionProvider = Provider.autoDispose<IntegrationConnection>((
  ref,
) {
  final all = ref.watch(integrationConnectionRegistryProvider);
  return all[IntegrationProvider.health] ??
      IntegrationConnection.initial(IntegrationProvider.health);
});
