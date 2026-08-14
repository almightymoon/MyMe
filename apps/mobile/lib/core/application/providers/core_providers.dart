import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/clock/app_clock.dart';

/// SharedPreferences — override in bootstrap and tests.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap/tests',
  );
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final appClockProvider = Provider<AppClock>((ref) => const SystemAppClock());
