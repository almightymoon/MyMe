# MeMy mobile route map

Audit of every navigable route and visible entry point in `/apps/mobile` as of the fake-repository MVP wiring milestone.

Back behavior: placeholder / feature routes use `context.pop()` when possible, otherwise `context.go('/today')`. Tab branches preserve stack via `StatefulShellRoute.indexedStack`.

| Route | Entry point | Destination | Current implementation status | Back-navigation behavior |
|------|-------------|-------------|-------------------------------|--------------------------|
| `/signin` | App launch (`initialLocation`) | `SignInScreen` | Demo auth only | N/A (root) |
| `/today` | Sign-in Continue; Today tab | `TodayScreen` | Wired to `TodayRepository` (fake) with loading / empty / error / populated | Tab root |
| `/plan` | Plan tab | `PlanScreen` | Wired to goals / habits / calendar repos independently | Tab root |
| `/coach` | Coach tab | `CoachScreen` | Wired to `CoachRepository` + local conversation controller (demo responses) | Tab root |
| `/more` | More tab | `MoreScreen` | Wired to `UserRepository` + module links | Tab root |
| `/goals` | Plan → Goals; Today → All | `GoalsListScreen` | Live — local persistence | Pop → previous (or Today) |
| `/goals/new` | Quick Add → Add Goal; Goals + | `AddGoalScreen` | Live — create + validate | Pop → previous |
| `/goals/:goalId` | Goals list / Today goal row | `GoalDetailScreen` | Live — detail, milestones, forecast | Pop or go `/goals` |
| `/habits` | Plan → Habits; Today → See all | `HabitsOverviewScreen` | Live — local/fake persistence | Pop → Plan (or Today) |
| `/habits/new` | Quick Add → Add Habit; Habits + | `AddHabitScreen` | Live — create + validate | Pop → previous |
| `/habits/:habitId` | Habits list / Today habit row | `HabitDetailScreen` | Live — detail, check-ins, status | Pop or go `/habits` |
| `/habits/:habitId/edit` | Detail → Edit | `EditHabitScreen` | Live — update + validate | Pop → detail |
| `/finance` | More → Finance; Today shortcut | `FinanceOverviewScreen` | Live — local/fake persistence | Pop → More (or Today) |
| `/finance/new` | Quick Add → Add Transaction; Finance + | `AddTransactionScreen` | Live — create + validate | Pop → previous |
| `/finance/history` | Finance → See All | `TransactionHistoryScreen` | Live — chronological list | Pop → Finance |
| `/finance/tx/:transactionId` | History / after save | `TransactionDetailScreen` | Live — detail, edit, delete | Pop or go history |
| `/finance/tx/:transactionId/edit` | Detail → Edit | `EditTransactionScreen` | Live — update + validate | Pop → detail |
| `/calendar` | Plan → Calendar card | `CalendarPlaceholderScreen` | Explicit Coming Soon placeholder | Pop → Plan (or Today) |
| `/calendar/new` | Quick Add → Add Event | `AddEventPlaceholderScreen` | Explicit Coming Soon placeholder | Pop → previous |
| `/health` | More → Health | `HealthPlaceholderScreen` | Explicit Coming Soon placeholder | Pop → More (or Today) |
| `/exercise` | More → Exercise | `ExercisePlaceholderScreen` | Explicit Coming Soon placeholder | Pop → More (or Today) |
| `/wardrobe` | More → Wardrobe | `WardrobePlaceholderScreen` | Explicit Coming Soon placeholder | Pop → More (or Today) |
| `/settings` | More → Settings | `SettingsScreen` | Explicit Coming Soon placeholder | Pop → More (or Today) |
| `/nutrition/coming-soon` | Quick Add → Log Meal | Nutrition Coming Soon view | Explicit labeled placeholder | Pop → previous |

## Visible button audit

| Control | Expected behavior | Status |
|---------|-------------------|--------|
| Sign-in → Continue to MeMy | Navigate to `/today` | Wired |
| Today tab | Branch to Today | Wired |
| Plan tab | Branch to Plan | Wired |
| Coach tab | Branch to Coach | Wired |
| More tab | Branch to More | Wired |
| Quick Add FAB | Open Quick Add sheet | Wired |
| Quick Add → Add Goal | `/goals/new` live form | Wired |
| Quick Add → Add Transaction | `/finance/new` live form | Wired |
| Quick Add → Add Event | `/calendar/new` placeholder | Wired |
| Quick Add → Add Habit | `/habits/new` live form | Wired |
| Quick Add → Log Meal | `/nutrition/coming-soon` placeholder | Wired |
| Plan Goals / Habits / Calendar cards | Push feature routes | Wired |
| Plan section Retry | Invalidate that section’s provider | Wired |
| Today Retry | Invalidate `todaySummaryProvider` | Wired |
| Coach suggested prompts | Append local demo conversation | Wired |
| Coach send | Append local “Demo response” | Wired |
| More module rows | Push module / settings routes | Wired |
| Placeholder Back | Pop or go `/today` | Wired |

No visible button silently no-ops; incomplete features land on an explicitly labeled Coming Soon / placeholder screen.
