# MeMy mobile interaction audit

Inventory of **visible interactive controls** across Flutter screens under `apps/mobile/lib/features`, plus screen-level uses of shared widgets (`ComingSoonView`, `EmptyFeatureCard`, `InlineErrorCard`).

**Audit date:** 2026-08-08  
**Scope:** Wiring, navigation, loading/error/empty states, accessibility, and test coverage — not new product features.

**Status legend**

| Status | Meaning |
|--------|---------|
| wired | Handler connected; navigates or persists as designed |
| partial | Interactive but demo-only / soft product behavior |
| placeholder | Destination or screen is intentional coming-soon |
| dead | Visible control with no meaningful handler |

**Test roots:** `apps/mobile/test/`

---

## Summary

| Area | Controls (approx.) | Notes |
|------|--------------------|-------|
| Shell + Quick Add | 10 | Quick Add non-goal destinations are placeholders |
| Auth | 4 | Demo sign-in; credentials unused |
| Today / Plan / Coach / More | ~23 | User-facing errors + Plan empty CTA fixed this audit |
| Goals (list / add / detail) | ~42 | Mutation guards, tooltips, Undo await fixed |
| Exercise | ~26 | Recent activity is non-interactive (labeled) |
| Placeholders | 10 | Back → `RoutePaths.today` |
| **Total** | **~115** | **0 dead interactive controls after fixes** |

---

## Quality fixes applied in this audit

| Issue | Fix |
|-------|-----|
| Raw `error.toString()` on Today / Plan / More / Coach | `userFacingErrorMessage` |
| Nested tap on Today goals card + rows | Outer card tap removed; rows remain tappable |
| Plan empty goals had no CTA | `EmptyFeatureCard` action → Add Goal |
| Unlabelled goal back / remove-milestone icons | Tooltips added |
| Coach send tooltip said “Demo response” | Tooltip = “Send message” |
| Save progress / milestone double-submit | Busy guards + snackbar errors |
| Delete Undo fired fire-and-forget | `await createGoal` + error snackbar |
| Placeholder backs used `'/today'` | `RoutePaths.today` |
| Exercise recent rows looked tappable | `enabled: false` + Semantics label |

---

## 1. App shell & bottom navigation

**Files:** `memy_app_shell.dart`, `memy_bottom_navigation.dart`

| Screen | Label | Action | Destination / state | Status | Tests |
|--------|-------|--------|---------------------|--------|-------|
| Bottom nav | Today | Switch branch | `/today` | wired | `widget_test.dart` |
| Bottom nav | Plan | Switch branch | `/plan` | wired | same |
| Bottom nav | Quick Add | Open sheet | `QuickAddSheet` | wired | `widget_test.dart` |
| Bottom nav | Coach | Switch branch | `/coach` | wired | `widget_test.dart` |
| Bottom nav | More | Switch branch | `/more` | wired | same |

---

## 2. Quick Add sheet

**File:** `quick_add_sheet.dart`

| Label | Destination | Status | Tests |
|-------|-------------|--------|-------|
| Add Goal | `/goals/new` | wired | goals_flow / api_goals_flow / widget_test |
| Add Transaction | `/finance/new` | placeholder | mapping unit only |
| Add Event | `/calendar/new` | placeholder | mapping unit only |
| Add Habit | `/habits/new` | placeholder | mapping unit only |
| Log Meal | `/nutrition/coming-soon` | placeholder | mapping unit only |

---

## 3. Auth — Sign in

| Label | Action | Status | Tests |
|-------|--------|--------|-------|
| Email / Password | Local fields (unused by Continue) | partial | presence only |
| Show/Hide password | Toggle obscure | wired | none |
| Continue to MeMy | `go(/today)` — no auth check | partial | `widget_test.dart` |

---

## 4. Today

| Label | Action | Status | Tests |
|-------|--------|--------|-------|
| Retry (error) | Invalidate today + goals | wired | `today_screen_test.dart` |
| All | `/goals` | wired | none |
| Goal row | `/goals/{id}` | wired | content via goals_flow |

---

## 5. Plan

| Label | Action | Status | Tests |
|-------|--------|--------|-------|
| Goals card | `/goals` | wired | goals_flow |
| Empty Goals → Add Goal | `/goals/new` | wired | none |
| Habits / Calendar cards | placeholder modules | placeholder | section render |
| Retry (Goals/Habits/Calendar) | Invalidate providers | wired | none |

---

## 6. Coach

| Label | Action | Status | Tests |
|-------|--------|--------|-------|
| Suggested prompts | Local demo conversation | partial | one prompt tested |
| Composer + Send | Local demo reply | partial | composer tested |
| Retry prompts | Invalidate | wired | none |

---

## 7. More

| Label | Destination | Status | Tests |
|-------|-------------|--------|-------|
| Finance / Health / Wardrobe / Settings | placeholders | placeholder | route_availability |
| Exercise | `/exercise` | wired | widget_test |
| Profile Retry | Invalidate profile | wired | none |

---

## 8. Goals — list / add / detail

| Control | Status | Tests |
|---------|--------|-------|
| Add / filters / refresh / open / archive / delete / Undo | wired | create/delete/milestone partially covered |
| Add Goal form fields + Save | wired | goals_flow + api_goals_flow |
| Detail: Archive/Delete/milestones/Save progress | wired | milestone completion covered |

---

## 9. Exercise

| Control | Status | Tests |
|---------|--------|-------|
| Back / categories / library / Start workout | wired or placeholder session | exercise_module_test |
| Library tile tap | snackbar (partial coaching) | list presence only |
| Recent activity rows | non-interactive (intentional) | none |

---

## 10. Placeholder / coming-soon screens

Habits, Add Habit, Finance, Add Transaction, Calendar, Add Event, Health, Wardrobe, Settings, Nutrition — **Back** → `pop` or `RoutePaths.today`. Status: **placeholder**. Covered by route availability; Back taps untested.

---

## Known gaps (accepted for this milestone)

1. Auth remains demo-only (no real session).
2. Coach remains local demo (no live model).
3. Finance / habits / calendar / health / wardrobe / settings / workout session are placeholders.
4. Many secondary controls lack dedicated widget tests (filters, archive, Undo, Save progress, Plan empty CTA).
5. Exercise library taps and Back buttons lightly covered.

---

## Backend companion notes

See also Goals API quality work in this audit:

- Exception filter no longer mis-codes Nest defaults as `GOAL_VALIDATION_ERROR` unless appropriate
- CORS `*` no longer pairs with `credentials: true`; production forbids `*`
- Health returns **503** when DB is down
- E2E cleanup scoped to fixture users
- DevAuth upserts configured user before attaching request user
- `includeArchived` validated as boolean after transform

---

*Source: `apps/mobile/lib/features`, `apps/mobile/lib/core/widgets`, `apps/mobile/lib/app/router`, `apps/mobile/test`.*
