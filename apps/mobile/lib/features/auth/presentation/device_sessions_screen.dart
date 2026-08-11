import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/widgets/memy_card.dart';
import '../application/auth_session_controller.dart';
import '../domain/auth_api.dart';

class DeviceSessionsScreen extends ConsumerWidget {
  const DeviceSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(authSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Device sessions')),
      body: FutureBuilder<List<AuthDeviceSession>>(
        future: ref.read(authApiProvider).listDevices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load device sessions.'));
          }
          final devices = snapshot.data;
          if (devices == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (devices.isEmpty) {
            return const Center(child: Text('No active devices.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.page),
            itemCount: devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final device = devices[index];
              final isCurrent = device.id == current?.deviceId;
              return MemyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceLabel ?? device.platform,
                      style: AppTextStyles.titleMedium(),
                    ),
                    Text(
                      '${device.platform} · ${device.appVersion}'
                      '${isCurrent ? ' · This device' : ''}',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    if (!isCurrent)
                      TextButton(
                        onPressed: () =>
                            ref.read(authApiProvider).revokeDevice(device.id),
                        child: const Text('Revoke'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
