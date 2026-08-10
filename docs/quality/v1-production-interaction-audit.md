# v1 Production Interaction Audit

Every interactive surface reachable in a production build
(`APP_ENV=production`), and an honest verdict on what it does.

Legend: **Live** = real behaviour on real local data. **Labelled placeholder**
= works, opens something, and says clearly that the deeper feature is not
built. **Demo content** = real UI, illustrative numbers. **Removed** = not
reachable in production.

## Entry and onboarding

| Surface | Verdict | Notes |
|---|---|---|
| First launch → `/onboarding` | Live | Six steps; completion persisted to `memy_onboarding_complete_v1` |
| Welcome / Privacy steps | Live | Copy only; no "AI" positioning |
| Preferences step | Live | Currency, units, week start, detected timezone, optional display name — all persisted |
| Calendar step → Connect | Live | Pushes `/calendar/connect`; no permission requested until tapped there |
| Calendar step → Skip | Live | Advances; nothing written |
| Health step → Connect / Skip | Live | Same pattern against `/health/connect` |
| Finish → Open Today | Live | Guarded against double-submit; navigates to `/today` |
| `/signin`, `/signup`, `/forgot-password` | Removed | Redirect to onboarding or Today |

## Bottom navigation

| Surface | Verdict | Notes |
|---|---|---|
| Today | Live shell, mixed content | Tasks are live and local; Life Score and focus copy are demo content |
| Plan | Live shell, mixed content | Module tiles navigate to live modules |
| Quick Add FAB | Live | Opens the sheet |
| More (Insights) | Live shell, demo figures | Trend/saved/goals numbers are illustrative; every tile navigates |
| Coach | Removed | Hidden; `/coach` redirects to Today |

## Quick Add

| Action | Verdict |
|---|---|
| Daily Task | Live — appends to Today's tasks |
| Goal | Live — `/goals/new` |
| Transaction | Live — `/finance/new` |
| Calendar Event | Live — `/calendar/new` |
| Habit | Live — `/habits/new` |
| Log Meal | Removed |

## Sidebar

| Item | Verdict |
|---|---|
| Account header → Profile | Live |
| Today, Plan | Live |
| Goals, Finance, Habits | Live, local persistence |
| Calendar | Live against the device calendar |
| Health | Live, read-only from platform Health |
| Exercise | Live browsing over bundled content |
| Connected Apps | Live |
| Appearance | Live |
| Settings | Live |
| Privacy & Data, Security, Help & Support, Legal, About | Live |
| Coach, Wardrobe, Body, Notifications | Removed |
| Sign Out | Removed — there is no session |

## Settings

| Row | Verdict |
|---|---|
| Profile Information | Live |
| Security | Live |
| Connected Apps | Live |
| Appearance | Live |
| Privacy | Live |
| Help & Support, Terms, Privacy Policy, About | Live |
| Reset onboarding | Live — clears the completion flag only, never user data |
| Units, Language | Removed (were snackbar-only) |
| Change Password | Removed (no auth provider) |
| Notifications | Removed (not built) |
| Log Out | Removed |

## Modules

| Surface | Verdict | Notes |
|---|---|---|
| Goals list / detail / add / edit / milestones | Live | Local repository |
| Finance overview / add / edit / history / detail | Live | Local repository |
| Habits overview / add / edit / detail / check-in | Live | Local repository |
| Calendar overview / add / edit / conflicts / recovery | Live | Device calendar + local mirror |
| Health overview / connect / permissions / workouts | Live | Read-only; permission-gated |
| Exercise overview and library | Live | Bundled demo content, labelled |
| Exercise item tap | Live sheet | Shows description, safety note, and a "coaching media is planned" note; routes to the workout placeholder |
| Workout session | Labelled placeholder | Explicitly says timers and form coaching are not live |

## Trust centre

| Surface | Verdict |
|---|---|
| Privacy & Data centre | Live |
| Export (v2) | Live — device-local archive |
| Delete local data | Live — scoped and global wipe; global wipe also resets onboarding |
| Integration diagnostics | Live — operational metadata only |
| Integration Lab | Removed in production; debug + capability gated elsewhere |
| Legal documents, Help articles, Report a problem, Feature request | Live |
| What's New | Live — safe error copy, no raw exceptions |

## Known demo content in production

These render real UI over illustrative numbers and are the main honesty debt
carried into v1:

- Today: Life Score ring, "Today's Focus" copy, weather-free glance card.
- Insights: Life Score trend, "PKR 12K" saved, "3 / 4" goals on track, tip
  card.
- Exercise: the bundled exercise and workout catalogue.

None of them accept input or promise a background process.
