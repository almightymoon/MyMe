# v1 Physical Device Smoke Tests

**Status:** Matrices defined below are **empty / not executed**. Do not treat any row as passed.

Purpose: owner-run confirmation on real hardware before store upload. Emulators/simulators are useful but do not close Health Connect / HealthKit / EventKit gates.

## Common setup

```bash
cd apps/mobile
flutter run --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none \
  --dart-define=SUPPORT_EMAIL=YOUR_INBOX_HERE
```

Install on a wiped profile or fresh install so onboarding appears.

---

## iOS physical matrix

| Device | OS | Tester | Date | Result | Notes |
|---|---|---|---|---|---|
| _TBD_ | _TBD_ | | | **Not executed** | |
| _TBD_ | _TBD_ | | | **Not executed** | |

### iOS script (check off on device)

- [ ] Cold start → onboarding (not demo sign-in)
- [ ] Preferences persist; Finish → Today; relaunch skips onboarding
- [ ] Calendar Connect shows system permission **only after tap**; Skip works
- [ ] Health Connect shows HealthKit permission **only after tap**; Skip works
- [ ] Goals / Finance / Habits CRUD smoke
- [ ] Create calendar event; edit; delete recovery path
- [ ] Health metrics populate when data exists; revoke/re-grant
- [ ] Export share sheet; scoped delete; global wipe returns to onboarding
- [ ] No Coach / Wardrobe / Body / Sign Out / Log Meal in production IA
- [ ] Legal drafts render; Help contact respects `SUPPORT_EMAIL`

---

## Android physical matrix

| Device | OS (prefer 14+) | Health Connect installed? | Tester | Date | Result | Notes |
|---|---|---|---|---|---|---|
| _TBD_ | _TBD_ | | | | **Not executed** | |
| _TBD_ | _TBD_ | | | | **Not executed** | |

### Android script (check off on device)

- [ ] Cold start → onboarding (not demo sign-in)
- [ ] Calendar permission only after Connect
- [ ] Health Connect permission flow only after Connect; rationale activity OK
- [ ] `ACTIVITY_RECOGNITION` / steps path when granted
- [ ] Goals / Finance / Habits CRUD smoke
- [ ] Export / deletion / wipe → onboarding
- [ ] Production IA freeze (no Coach, meal log, Sign Out)
- [ ] Release binary **not** relied upon for Play upload while still debug-signed

---

## Screenshot capture (separate pass)

| Frame | Captured? | Build mode used |
|---|---|---|
| Today | No | |
| Goals | No | |
| Finance | No | |
| Habits | No | |
| Calendar | No | |
| Health | No | |
| Privacy | No | |

Internal deterministic mode (optional, never production):

`--dart-define=APP_ENV=internal --dart-define=STORE_SCREENSHOT_MODE=true`
