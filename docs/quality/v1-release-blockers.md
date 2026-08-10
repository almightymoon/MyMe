# v1 Release Blockers

Status for the MeMy **1.0.0+1** release-candidate track.

**Code P0 / P1:** none open. Remaining ship gates are **owner-blocked** (device QA, legal, store URLs, signing, remote CI confirmation).

## Resolved by the feature freeze (engineering)

| # | Blocker | Resolution | Evidence |
|---|---|---|---|
| 1 | Cold start landed on a demo sign-in screen with no real auth | Production resolves `AUTH_MODE=none` and starts at onboarding, then Today | `test/features/onboarding/onboarding_flow_test.dart` |
| 2 | No first-run setup; currency/units/week start were never asked | Local onboarding flow persists them to SharedPreferences | `test/features/onboarding/onboarding_preferences_test.dart` |
| 3 | Fake repositories could be shipped via dart-define | Production forces Goals/Finance/Habits to `local`, Calendar/Health to `system`; `EnvironmentConfig.validate()` fails the build in debug | `test/core/config/release_configuration_test.dart` |
| 4 | "AI Coach" was a primary tab backed by scripted local content | Hidden in production nav and sidebar; `/coach` redirects to Today; internal builds label it "Coach Preview" | `test/features/routing/production_navigation_test.dart` |
| 5 | Sidebar advertised Wardrobe, Body and a "Planned" Notifications row | Filtered through `ReleaseCapabilities`; routes redirect to Today | same |
| 6 | Quick Add offered Log Meal, which led to a coming-soon page | Removed in production; route redirects | same |
| 7 | Sign Out implied an account that does not exist | Hidden whenever demo auth is off, in both drawer and Settings | same |
| 8 | Settings Units/Language rows only produced a "planned" snackbar | Hidden unless `SHOW_PLANNED_FEATURES` | same |
| 9 | Exercise library tap produced a dead "coming later" snackbar | Opens a real detail sheet (description, safety note, planned-media note) with a route into the labelled workout placeholder | manual + `test/features/exercise/exercise_module_test.dart` |
| 10 | What's New surfaced a raw exception string | Replaced with a safe user-facing message | code review |
| 11 | Global preference wipe left onboarding marked complete | Onboarding keys registered in `MemyOwnedPreferenceKeys` and included in the preferences wipe | `test/features/onboarding/onboarding_preferences_test.dart` |
| 12 | Integration Lab reachable from any debug build | Additionally gated on `ReleaseCapabilities.debugIntegrationLab` (route and Connected Apps entry) | code review |

## Accepted for v1 (not blockers)

- **Insights is a navigation hub**, not a live analytics engine. Cards route into Finance/Goals and explain that summaries grow from local tracking.
- **Profile fields are local and lightly used.** Editing works and persists; there is simply not much to attach to yet.
- **Exercise content is bundled demo data**, labelled as such.
- **Workout session screen is an explicit placeholder**, labelled as planned.
- **Legal documents remain Draft** until owner/counsel approval — tracked as owner-blocked, not a code defect.
- **Release AAB still points at the debug keystore locally** — tracked as owner signing action, not an unfinished feature.

## Owner-blocked before store upload

These are **not** open code P0/P1. They must be completed by the owner (and counsel where noted) before submission. See `docs/release/owner-actions.md`.

| # | Gate | Class | Status |
|---|---|---|---|
| O1 | Physical iOS device smoke (HealthKit + calendar prompts only after Connect) | Device QA | **Not executed** — matrix empty |
| O2 | Physical Android 14+ smoke (Health Connect permission flow) | Device QA | **Not executed** — matrix empty |
| O3 | Export and deletion end-to-end on device | Device QA | **Not executed** |
| O4 | Screenshot pass for store listings | Store assets | **Not executed** |
| O5 | Legal counsel review of Draft Privacy / Terms / Health / Financial | Legal | Open |
| O6 | Host public Privacy Policy URL (none yet) | Store / legal | Open |
| O7 | Set `SUPPORT_EMAIL` for production builds (empty by default) | Store / support | Open |
| O8 | Create Play App Signing upload keystore; stop shipping debug-signed release AABs | Signing | Open |
| O9 | iOS distribution signing + App Store Connect app record | Signing | Open |
| O10 | Confirm `ITSAppUsesNonExemptEncryption=false` with legal | Legal | Open |
| O11 | Confirm remote CI green on the release commit | Release eng | **Not verified in this session** |

## Related docs

- `docs/quality/v1-release-candidate-checklist.md`
- `docs/quality/v1-physical-device-smoke-tests.md`
- `docs/release/owner-actions.md`
- `docs/product/post-v1-backlog.md`
