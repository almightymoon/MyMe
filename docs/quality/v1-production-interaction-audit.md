# v1 Production Interaction Audit

Every interactive surface reachable in a production build
(`APP_ENV=production`), and an honest verdict on what it does.

Legend: **Live** = real behaviour on real local data. **Labelled catalogue**
= static bundled content, not personal history. **Removed** = not reachable in
production.

Updated with the final application-completion honesty pass.

## Entry and onboarding

| Surface | Verdict | Notes |
|---|---|---|
| First launch → `/onboarding` | Live | Six steps; completion persisted to `memy_onboarding_complete_v1` |
| Welcome / Privacy steps | Live | Copy only; no live-AI positioning |
| Preferences step | Live | Currency, units, week start, detected timezone, optional display name |
| Calendar / Health Connect or Skip | Live | Permissions only after Connect |
| Finish → Open Today | Live | Double-submit guarded |
| `/signin`, `/signup`, `/forgot-password` | Removed | Redirect |

## Bottom navigation

| Surface | Verdict | Notes |
|---|---|---|
| Today | Live | Greeting from onboarding display name; modules from live providers; no Life Score / fake focus in production |
| Plan | Live | Goals/Habits/Finance/Health/Calendar from live providers; Wardrobe/Body/Nutrition/Coach strip hidden |
| Quick Add FAB | Live | Single sheet; no stacking |
| More (Insights) | Live shell | Honest weekly summary copy; no fabricated PKR/goals track tiles as live metrics |
| Coach | Removed | Hidden; `/coach` → Today |

## Quick Add

| Action | Verdict |
|---|---|
| Daily Task | Live |
| Goal / Transaction / Event / Habit | Live |
| Log Meal | Removed |

## Sidebar / More destinations

Profile, Goals, Finance, Habits, Calendar, Health, Exercise, Connected Apps,
Appearance, Settings, Privacy, Security, Help, Legal, About — **Live**.

Coach, Wardrobe, Body, Notifications, Sign Out — **Removed**.

## Exercise

| Surface | Verdict |
|---|---|
| Overview categories + featured card | Labelled catalogue |
| Library + detail sheet | Labelled catalogue (description, safety, muscles) |
| Start Workout / weekly summary / recent activity | Removed in production |
| `/exercise/session` | Redirects to `/exercise` in production |

## Modules (Goals / Finance / Habits / Calendar / Health)

All CRUD, check-in, sync/recovery, and permission flows listed in
`v1-screen-logic-matrix.md` are **Live** with loading/empty/error/retry,
duplicate-submit protection on saves, and cross-feature refresh without restart.

## Trust / Support / Legal / About

Export v2, scoped deletion, diagnostics (allowlisted), Help offline articles,
Contact/Report/Feature share flows, Security (truthful, no MFA/E2E claims),
Legal markdown, About + What’s New — **Live**.

Integration Lab — **Removed** in production.

## Dead / misleading controls closed in this pass

| Control | Resolution |
|---|---|
| Plan “95 bpm” / “Team Meeting” hardcodes | Replaced with `todayHealthSummaryProvider` / `todayCalendarEventsProvider` |
| Plan Wardrobe / Nutrition / Body / Coach strip in production | Hidden via `ReleaseCapabilities` |
| Today greeting “Emma” from `FakeTodayRepository` | `displayNameProvider` + local onboarding prefs; production base summary has no seed focus |
| Production Start Workout | Hidden; session route redirects to Exercise |
| `/settings/notifications` deep link | Redirects to Settings |

## Remaining honesty (accepted catalogue, not user data)

- Exercise library artwork and catalogue rows are bundled content.
- More Insights remains a navigation hub, not a fabricated analytics product.

No open dead production button remains for mutating actions.
