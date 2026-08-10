# Integration roadmap

MeMy becomes a connected personal-life operating system in phased integrations.

## Phase 1 — Implemented in this milestone

| Integration | Platforms | Mode |
|-------------|-----------|------|
| Apple HealthKit | iOS | Read-only wellness metrics |
| Health Connect | Android | Read-only wellness metrics |
| Device calendars | iOS EventKit / Android Calendar Provider | Two-way for MeMy-owned events; import external as read-only |

See:

- [`health-platform-integration.md`](health-platform-integration.md)
- [`device-calendar-sync.md`](device-calendar-sync.md)
- [`../architecture/integration-foundation.md`](../architecture/integration-foundation.md)
- [`../privacy/health-data-flow.md`](../privacy/health-data-flow.md)
- [`../privacy/calendar-data-flow.md`](../privacy/calendar-data-flow.md)

## Phase 2 — Cloud calendar, context, notifications

| Integration | User benefit | Permissions | Data class | Storage | Backend |
|-------------|--------------|-------------|------------|---------|---------|
| Google Calendar OAuth | Cross-device schedule | Google OAuth calendar scopes | Schedule | Local + optional sync token | Yes |
| Microsoft Outlook / Graph | Work calendar | Graph calendar scopes | Schedule | Local + sync | Yes |
| Background calendar sync | Fresh agenda without opening app | BG refresh / push | Schedule | Local | Optional |
| Local notifications | Habit/event reminders | Notification permission | Reminder metadata | Local | No |
| Maps / travel time / traffic | Leave-by suggestions | Location when used | Location ephemeral | Ephemeral | Optional |
| Weather-aware prep | Outfit / outdoor context | Location or city | Weather cache short-lived | Local short TTL | Optional |

Conflict handling: same fingerprint model as device calendar; cloud events remain externally identified by stable provider IDs.

Failure behavior: local MeMy agenda remains usable; sync pending badges; never silent overwrite.

## Phase 3 — Vendor wearables

| Integration | Benefit | Permissions | Notes |
|-------------|---------|-------------|-------|
| Garmin | Deeper training metrics | Vendor OAuth | Source-priority rules vs HealthKit/HC |
| Fitbit | Activity continuity | Vendor OAuth | Deduplicate vs platform store |
| Oura | Sleep / readiness (non-diagnostic) | Vendor OAuth | No medical claims |
| WHOOP | Strain / recovery (non-diagnostic) | Vendor OAuth | No medical claims |

Data classification: wellness telemetry. Prefer platform stores when already mirrored; vendor APIs only for unique fields. Backend may store sync tokens, never raw biometrics unless a future privacy review explicitly allows it.

## Phase 4 — Email, contacts, documents

| Integration | Benefit | Sensitivity |
|-------------|---------|-------------|
| Email receipt / bill extraction | Finance automation | High — minimize retention |
| Travel itinerary extraction | Calendar prep | High |
| Contacts / birthdays | Social reminders | High |
| Subscription discovery | Finance clarity | Medium |
| Document vault | Secure storage | High — encrypted |

## Phase 5 — Home and vehicle

| Integration | Benefit |
|-------------|---------|
| Smart-home | Routines / energy context |
| Vehicle telematics | Maintenance reminders |
| Insurance / retirement | Long-horizon Goals |

## Platform review requirements (all future phases)

- Minimal scoped permissions
- In-app pre-permission explanations
- Redacted logging
- Disconnect + delete local caches
- Fake gateways for CI
- No health write / clinical scopes without a dedicated milestone
