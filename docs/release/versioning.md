# Versioning

## Current release candidate

| Layer | Value |
|---|---|
| Marketing / store version | **1.0.0** |
| Android `versionCode` / iOS `CFBundleVersion` | **1** |
| `pubspec.yaml` | `1.0.0+1` |
| Flutter SDK (this machine) | 3.44.9 |
| Dart SDK | 3.12.2 |

Flutter maps `1.0.0+1` as:

- **Android:** `versionName=1.0.0`, `versionCode=1`
- **iOS:** `CFBundleShortVersionString=1.0.0`, `CFBundleVersion=1`

## Rules for subsequent builds

1. Every Play / App Store upload must bump the **build number** (`+N`).
2. User-facing store “What’s New” text follows the **marketing** version (`1.0.0`, `1.0.1`, …).
3. Keep `apps/mobile/assets/trust/changelog/whats-new.md` aligned with the marketing version shipped.
4. Do not reuse a Play `versionCode` or App Store build number already uploaded.

## Override at build time (optional)

```bash
flutter build appbundle --build-name=1.0.0 --build-number=2 \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
```

Prefer updating `pubspec.yaml` so local runs and CI stay consistent.
