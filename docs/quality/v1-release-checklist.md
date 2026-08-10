# v1 Release Checklist

## Build configuration

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] Production build uses `--dart-define=APP_ENV=production --dart-define=AUTH_MODE=none`
- [ ] No `GOALS_/FINANCE_/HABITS_DATA_SOURCE=fake` in the release pipeline
- [ ] A debug run with `APP_ENV=production` starts without tripping
      `EnvironmentConfig.validate()`

## First run

- [ ] Fresh install opens onboarding, never a sign-in screen
- [ ] Preferences step persists currency, units, week start, timezone and
      optional display name
- [ ] Calendar and Health steps request **no** permission until the user taps
      Connect on the respective connection screen
- [ ] Skip works on both optional steps
- [ ] Finish opens Today and cannot be double-submitted
- [ ] Relaunch goes straight to Today

## Navigation freeze

- [ ] Bottom nav: Today, Plan, Quick Add, More — no Coach
- [ ] Quick Add: Daily Task, Goal, Transaction, Calendar Event, Habit — no
      Log Meal
- [ ] Sidebar matches `docs/product/v1-scope.md`; no Coach, Wardrobe, Body,
      Notifications or Sign Out
- [ ] Deep links to `/coach`, `/wardrobe`, `/body`,
      `/nutrition/coming-soon`, `/signin` all land somewhere sensible
- [ ] Settings shows no Units, Language, Change Password, Notifications or
      Log Out rows

## Modules on device

- [ ] Goals: create, edit, milestone, archive, delete
- [ ] Finance: add income and expense, edit, delete, period switch
- [ ] Habits: create, check in, streak, history, edit, delete
- [ ] Calendar: permission prompt, event create/edit/delete, conflict and
      recovery paths
- [ ] Health: permission prompt, metrics populate, workouts list, revoke and
      re-grant
- [ ] Exercise: category filter, item sheet, workout placeholder

## Trust

- [ ] Export produces a readable archive and shares successfully
- [ ] Scoped deletion removes only the chosen module
- [ ] Global wipe clears data **and** resets onboarding so the next launch
      shows setup again
- [ ] Diagnostics contain no personal content
- [ ] Legal documents and Help articles render

## Platform

- [ ] iOS: HealthKit entitlement present, `NSHealthShareUsageDescription`
      set, no write usage description
- [ ] iOS: calendar usage descriptions set
- [ ] Android: Health Connect permissions declared, no `WRITE_*` health
      permission, `ACTIVITY_RECOGNITION` present
- [ ] Android: `MainActivity` extends `FlutterFragmentActivity`

## Store readiness

- [ ] Screenshots captured from a production build
- [ ] Listing copy uses "Your Personal Life Companion" and does not claim AI
- [ ] Privacy nutrition labels reflect local-only storage
- [ ] `apps/mobile/assets/trust/changelog/whats-new.md` has the v1 entry
