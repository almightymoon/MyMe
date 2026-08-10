# iOS Permissions & Usage Strings

Declared in `apps/mobile/ios/Runner/Info.plist`. Bundle id: `com.moontech.memy`. Deployment target: **14.0**.

## HealthKit (read-only)

| Key | Value |
|---|---|
| `NSHealthShareUsageDescription` | MeMy reads the activity, heart-rate, sleep, and workout data you choose so it can display your personal wellness dashboard. MeMy does not write health data. |

Intentionally **omitted**:

- `NSHealthUpdateUsageDescription` (MeMy does not write to HealthKit)
- HealthKit Write capability

Entitlement: `com.apple.developer.healthkit` via Runner entitlements / Signing & Capabilities. Confirm the capability remains enabled on the Apple Developer portal for the App ID before archive upload.

## Calendar

| Key | Value |
|---|---|
| `NSCalendarsFullAccessUsageDescription` | MeMy accesses the calendars you select so your schedule can appear in MeMy and MeMy-created events can be added to your chosen calendar. |
| `NSCalendarsUsageDescription` | Same copy (legacy key retained for older OS paths) |

Requested from the Calendar connection flow — **not** at cold start.

## Export compliance key

| Key | Value |
|---|---|
| `ITSAppUsesNonExemptEncryption` | `false` |

Assumption: ordinary HTTPS / OS crypto only. **Legal must confirm** before relying on this for App Store Connect answers. See `docs/release/apple-export-compliance.md`.

## Not requested (v1)

- Push notifications / UNUserNotificationCenter scheduling
- Location, camera, microphone, contacts, photo library (beyond what Flutter plugins might pull transitively — none declared in Info.plist for those uses)
- Live AI network entitlements specific to a model vendor

## Runtime posture

Production forces system Calendar and Health. Physical-device confirmation of delayed permission prompts remains **owner QA**.
