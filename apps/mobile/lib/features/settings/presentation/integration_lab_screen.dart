import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/integrations/domain/integration_availability.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../calendar/application/providers/calendar_providers.dart';
import '../../calendar/data/gateways/fake_device_calendar_gateway.dart';
import '../../calendar/domain/entities/calendar_event_lookup_result.dart';
import '../../calendar/domain/entities/calendar_read_batch.dart';
import '../../health/application/providers/health_providers.dart';
import '../../health/data/gateways/fake_platform_health_gateway.dart';
import '../../health/domain/entities/health_metric_type.dart';

/// Debug-only Integration Lab. Excluded from release navigation.
///
/// Deterministic QA against fake gateways — never seeds real Health values
/// into logs.
class IntegrationLabScreen extends ConsumerWidget {
  const IntegrationLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(kDebugMode, 'Integration Lab is debug-only');

    return Scaffold(
      key: const Key('integration_lab'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Integration Lab',
              subtitle: 'Debug-only fake gateway scenarios',
              leading: IconButton(
                key: const Key('integration_lab_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.connectedApps),
                icon: const Icon(Icons.arrow_back_rounded),
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
                  Text('Calendar (fake)', style: AppTextStyles.titleMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  _LabButton(
                    key: const Key('lab_calendar_complete'),
                    label: 'Complete read batches',
                    onPressed: () {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.forcePartialBatches = false;
                        gateway.nextBatchCompleteness =
                            CalendarReadCompleteness.complete;
                        _snack(context, 'Calendar batches → complete');
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_calendar_partial'),
                    label: 'Partial read batches',
                    onPressed: () {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.forcePartialBatches = true;
                        gateway.nextBatchCompleteness =
                            CalendarReadCompleteness.partial;
                        _snack(context, 'Calendar batches → partial');
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_calendar_unavailable'),
                    label: 'Provider unavailable',
                    onPressed: () {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.setAvailability(
                          IntegrationAvailability.unavailable,
                        );
                        _snack(context, 'Calendar availability → unavailable');
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_calendar_lookup_unknown'),
                    label: 'Lookup returns unknown',
                    onPressed: () {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.defaultLookupOverride =
                            CalendarEventLookupUnknown(
                              sanitizedErrorCode: 'unknown',
                              retryable: true,
                              checkedAt: DateTime.now().toUtc(),
                            );
                        _snack(context, 'Next getEventById → unknown');
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_calendar_hydration_fail'),
                    label: 'Simulate hydration provider failure',
                    onPressed: () async {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.throwOnAvailabilityCheck = true;
                        final sync = ref.read(calendarSyncServiceProvider);
                        await sync.hydrateConnectionFromPersistence();
                        gateway.throwOnAvailabilityCheck = false;
                        if (context.mounted) {
                          _snack(
                            context,
                            'Hydration → staleCacheAvailable (not connected)',
                          );
                        }
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_calendar_lookup_not_found'),
                    label: 'Lookup returns verified not-found',
                    onPressed: () {
                      final gateway = ref.read(deviceCalendarGatewayProvider);
                      if (gateway is FakeDeviceCalendarGateway) {
                        gateway.defaultLookupOverride = CalendarEventNotFound(
                          externalCalendarId: 'cal_lab',
                          externalEventId: 'evt_lab',
                          verifiedAt: DateTime.now().toUtc(),
                          verificationMethod: 'fakeMapMiss',
                        );
                        _snack(context, 'Next getEventById → notFound');
                      } else {
                        _snack(context, 'Switch CALENDAR_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Health (fake)', style: AppTextStyles.titleMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  _LabButton(
                    key: const Key('lab_health_ios_cancelled'),
                    label: 'iOS-style cancelled request',
                    onPressed: () {
                      final gateway = ref.read(platformHealthGatewayProvider);
                      if (gateway is FakePlatformHealthGateway) {
                        gateway.treatRequestsAsUnverified = true;
                        gateway.nextRequestOutcome =
                            FakePermissionRequestOutcome.cancelled;
                        _snack(context, 'Next request → requestCancelled');
                      } else {
                        _snack(context, 'Switch HEALTH_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_health_ios_failed'),
                    label: 'iOS-style failed request',
                    onPressed: () {
                      final gateway = ref.read(platformHealthGatewayProvider);
                      if (gateway is FakePlatformHealthGateway) {
                        gateway.treatRequestsAsUnverified = true;
                        gateway.nextRequestOutcome =
                            FakePermissionRequestOutcome.failed;
                        _snack(context, 'Next request → requestFailed');
                      } else {
                        _snack(context, 'Switch HEALTH_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_health_ios_unverified'),
                    label: 'iOS-style unverified dispositions',
                    onPressed: () {
                      final gateway = ref.read(platformHealthGatewayProvider);
                      if (gateway is FakePlatformHealthGateway) {
                        gateway.treatRequestsAsUnverified = true;
                        gateway.nextRequestOutcome = null;
                        _snack(
                          context,
                          'Next grant → unverified (HealthKit-style)',
                        );
                      } else {
                        _snack(context, 'Switch HEALTH_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_health_verified_partial'),
                    label: 'Android-style verified Activity+Heart only',
                    onPressed: () {
                      final gateway = ref.read(platformHealthGatewayProvider);
                      if (gateway is FakePlatformHealthGateway) {
                        gateway.treatRequestsAsUnverified = false;
                        gateway.nextRequestGrantsOverride = {
                          HealthMetricGroup.activity,
                          HealthMetricGroup.heartRate,
                        };
                        _snack(context, 'Next grant → verified partial');
                      } else {
                        _snack(context, 'Switch HEALTH_DATA_SOURCE=fake');
                      }
                    },
                  ),
                  _LabButton(
                    key: const Key('lab_health_unavailable'),
                    label: 'Health provider unavailable',
                    onPressed: () {
                      final gateway = ref.read(platformHealthGatewayProvider);
                      if (gateway is FakePlatformHealthGateway) {
                        gateway.setAvailability(
                          IntegrationAvailability.unavailable,
                        );
                        _snack(context, 'Health availability → unavailable');
                      } else {
                        _snack(context, 'Switch HEALTH_DATA_SOURCE=fake');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LabButton extends StatelessWidget {
  const _LabButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          ),
          onPressed: onPressed,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: AppTextStyles.bodyMedium()),
          ),
        ),
      ),
    );
  }
}
