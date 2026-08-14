# MeMy v1 Scope

MeMy v1 is a **local-first personal life companion**. Everything a person
records lives on their device. There is no MeMy account, no cloud sync, and no
live AI model.

Tagline: **Your Personal Life Companion.**

## In scope

| Area | What ships | Storage |
|---|---|---|
| Onboarding | Local first-run setup: welcome, privacy, preferences (currency, units, week start, timezone, optional display name), optional Calendar, optional Health, finish | SharedPreferences |
| Goals | Create, edit, archive, milestones, progress and forecasts | Local (SharedPreferences JSON) |
| Finance | Income/expense transactions, categories, monthly budgets, reports, money owed | Local |
| Habits | Habits, schedules, check-ins, streaks and history | Local |
| Calendar | Read and write device calendar events via `device_calendar`, conflict and recovery handling | Device calendar + local SQLite (Drift) |
| Health | Read-only steps, distance, calories, heart rate, sleep, weight, workouts from HealthKit / Health Connect | Platform Health (never written) |
| Exercise | Category browsing, exercise library with safety notes, labelled workout-session placeholder | Bundled content |
| Wardrobe | Items, private photos, outfits, local suggestions, date plans, wear history | Local JSON + app-private files |
| Trust | Privacy & Data centre, export, deletion, diagnostics, legal, help, about | Local |
| Appearance | Theme mode and reduce motion | SharedPreferences |

## Out of scope for v1

Frozen out of the production build entirely — the code may exist behind
`ReleaseCapabilities`, but production cannot reach it:

- **Coach / live AI.** No model is contacted. The local scripted Coach Preview
  is internal-only.
- **Notifications and reminders.** No scheduling engine exists.
- **Nutrition / Log Meal.** No food database or logging model.
- **Body composition**. Placeholder-quality only.
- **Wardrobe AI, cloud photos, shopping, or live weather-driven outfits.** Suggestions are on-device rules only.
- **Direct wearable SDKs** (Garmin, Fitbit, Whoop). Health data comes only
  from the platform Health store.
- **Cloud account, cloud sync, OAuth, bank connections.**
- **Maps.**

## Navigation in production

- **Bottom navigation:** Today, Plan, Quick Add, More. Coach is hidden; the
  shell still owns four branches so indices stay stable.
- **Quick Add:** Daily Task, Goal, Transaction, Calendar Event, Habit. Log
  Meal is removed.
- **Sidebar:** account header (Profile) → Today, Plan → Goals, Finance,
  Habits, Calendar, Health, Exercise → Connected Apps, Appearance, Settings →
  Privacy & Data, Security, Help & Support, Legal, About MeMy. There is no
  Sign Out because there is no session.

## Data and privacy posture

- No network calls are required to use any v1 feature.
- Production builds start with **empty** Goals, Finance transactions, Habits,
  and Today checklist items — never bundled demo records presented as yours.
- Finance keeps deterministic built-in categories so you can add transactions.
- Export produces a device-local archive; deletion is genuinely local.
- Preference wipe also resets onboarding, so a wiped device behaves like a
  first launch.

**Scope freeze:** No new v1 feature may be added without removing another item
or changing the release target.

See `docs/architecture/v1-release-configuration.md` for how the freeze is
enforced, and `docs/quality/v1-production-interaction-audit.md` for the
per-surface audit.
