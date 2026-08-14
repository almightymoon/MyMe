# MeMy App Identity

| Field | Value |
|---|---|
| Product name | MeMy |
| Organization | MoonTech |
| Tagline | Your Personal Life Companion |
| Android `applicationId` / `namespace` | `com.moontech.memy` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.moontech.memy` |
| Display name | MeMy |
| Flutter package name | `memy` |
| Marketing version | 1.0.0 |
| Build number | 1 |
| `pubspec` version | `1.0.0+1` |

## Positioning (store-safe)

MeMy is a **local-first personal life companion**. Goals, finance, habits, and preferences live on the device. Calendar and Health use the device’s system stores when the user chooses to connect them.

Production v1 does **not**:

- create a MeMy cloud account
- sync data to MeMy servers
- connect to banks
- call a live AI model
- schedule notifications or reminders
- make medical diagnoses or treatment claims

## Source of truth

- Android: `apps/mobile/android/app/build.gradle.kts` (`applicationId`, `namespace`)
- iOS: `apps/mobile/ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`)
- Version: `apps/mobile/pubspec.yaml`
- Product scope: `docs/product/v1-scope.md`
