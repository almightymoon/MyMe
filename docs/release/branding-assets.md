# Branding Assets

## Store source artwork

Generated under `apps/mobile/assets/branding/store/`:

| File | Role |
|---|---|
| `app-icon-1024.png` | Master 1024×1024 app icon (App Store / general) |
| `play-icon-512.png` | Google Play high-res icon (512×512) |
| `play-feature-graphic-1024x500.png` | Play feature graphic |
| `adaptive-foreground-1024.png` | Android adaptive icon foreground |
| `adaptive-background-1024.png` | Android adaptive icon background |

## In-app branding

Runtime Flutter assets still load from `apps/mobile/assets/images/branding/` and `assets/images/modules/` (see `pubspec.yaml`). Store folder assets are for Console / Connect upload and adaptive-icon generation — confirm mipmap / xcassets were regenerated from these masters before submission.

## Adaptive launcher (Android)

Adaptive XML lives under `apps/mobile/android/app/src/main/res/mipmap-anydpi-v26/`. Verify the adaptive layers match the store masters before Play upload.

## Rules

- Do not place `STORE_SCREENSHOT_MODE` screenshots into production builds.
- Keep wordmark “MeMy” and MoonTech attribution consistent with `docs/release/app-identity.md`.
- Do not invent a hosted brand CDN URL; assets are repo-local until the owner publishes them.
