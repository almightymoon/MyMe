# iOS Build (Release Candidate)

## Tooling

| Item | Value |
|---|---|
| Flutter | 3.44.9 |
| Dart | 3.12.2 |
| Bundle ID | `com.moontech.memy` |
| Deployment target | **14.0** |
| Version | `1.0.0+1` → short version 1.0.0 / build 1 |
| Display name | MeMy |

## Production dart-defines

```bash
cd apps/mobile

flutter build ipa --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
```

Optional:

```bash
  --dart-define=SUPPORT_EMAIL=you@your-domain.example
```

Production forces local Goals/Finance/Habits, system Calendar/Health, no fake repos, no Integration Lab, no live AI, no demo seed. `STORE_SCREENSHOT_MODE` is forced off.

## Capabilities & plist

Before archive:

- [ ] HealthKit capability enabled for App ID / provisioning
- [ ] `NSHealthShareUsageDescription` present; no update usage string
- [ ] Calendar usage strings present
- [ ] `ITSAppUsesNonExemptEncryption` matches legal determination (`false` currently — **legal must confirm**)
- [ ] Signing team / distribution certificate / App Store provisioning profile configured in Xcode

## Signing — owner action required

Apple distribution signing, certificates, and App Store Connect app record are **owner-operated**. This pack does not claim an archive was uploaded or TestFlight-processed.

## Smoke commands (local / macOS)

```bash
flutter analyze
flutter test
flutter build ios --release --no-codesign \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
# Prefer a full `flutter build ipa` once signing is configured.
```

## Remote CI

`mobile-ios-ci.yml` exists. **Pass/fail was not verified in the session that authored this release pack.**

## Screenshot mode (not for production)

```bash
flutter run \
  --dart-define=APP_ENV=internal \
  --dart-define=STORE_SCREENSHOT_MODE=true
```
