# Android Permissions

Declared in `apps/mobile/android/app/src/main/AndroidManifest.xml`.

## Health Connect (read-only)

| Permission | Purpose |
|---|---|
| `android.permission.health.READ_STEPS` | Steps |
| `android.permission.health.READ_DISTANCE` | Distance |
| `android.permission.health.READ_ACTIVE_CALORIES_BURNED` | Active calories |
| `android.permission.health.READ_HEART_RATE` | Heart rate |
| `android.permission.health.READ_RESTING_HEART_RATE` | Resting heart rate |
| `android.permission.health.READ_SLEEP` | Sleep |
| `android.permission.health.READ_EXERCISE` | Workouts / exercise sessions |
| `android.permission.health.READ_WEIGHT` | Weight |
| `android.permission.ACTIVITY_RECOGNITION` | Required by Health Connect for Steps |

**No `WRITE_*` health permissions** are declared. MeMy never writes to Health Connect.

Supporting pieces:

- Intent filter: `androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE`
- Activity alias `ViewPermissionUsageActivity` for Health Connect permission-usage UI
- Package query for `com.google.android.apps.healthdata`

## Calendar

| Permission | Purpose |
|---|---|
| `android.permission.READ_CALENDAR` | Read selected calendars |
| `android.permission.WRITE_CALENDAR` | Create/update MeMy events on the chosen calendar |

Requested from the Calendar connection flow — **not** at cold start.

## Not declared (v1)

- `POST_NOTIFICATIONS` / notification scheduling
- Location / microphone / camera
- Contacts
- Bank / financial institution OAuth SDKs
- Background location

## Runtime posture

Production uses `HEALTH_DATA_SOURCE=system` and `CALENDAR_DATA_SOURCE=system` (forced). Permission prompts should appear only after an explicit Connect action. Physical-device confirmation is still an **owner QA** item — see `docs/quality/v1-physical-device-smoke-tests.md`.
