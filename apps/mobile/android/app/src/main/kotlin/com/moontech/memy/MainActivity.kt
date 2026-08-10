package com.moontech.memy

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by the `health`
// plugin on Android 14+: Health Connect permission requests use
// registerForActivityResult, which needs an Activity castable to
// ComponentActivity. See lib/core/config/environment_config.dart
// HealthDataSource docs.
class MainActivity : FlutterFragmentActivity()
