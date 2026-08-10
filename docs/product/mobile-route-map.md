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
| `/calendar` | Plan → Calendar; Settings → Connections | `CalendarOverviewScreen` | Live — fake/system device calendars | Pop → Plan |
| `/calendar/new` | Quick Add → Add Event | `AddCalendarEventScreen` | Live — MeMy event + pending push | Pop → previous |
| `/calendar/connect` | Calendar banner / Connections | `CalendarConnectionScreen` | Live — permission + connect | Pop |
| `/calendar/connect/select` | After connect | `CalendarSelectionScreen` | Live — readable/writable selection | Pop |
| `/calendar/conflicts` | Sync conflicts | `CalendarConflictScreen` | Live | Pop |
| `/calendar/recovery` | Create recovery cases | `CalendarRecoveryScreen` | Live | Pop |
| `/calendar/event/:eventId` | Agenda row | `CalendarEventDetailScreen` | Live | Pop |
| `/calendar/event/:eventId/edit` | Detail → Edit (MeMy-owned) | `EditCalendarEventScreen` | Live | Pop |
| `/health` | More → Health; Today CTA | `HealthOverviewScreen` | Live — fake/system Health | Pop → More |
| `/health/connect` | Health / Connections | `HealthConnectionScreen` | Live — explanation | Pop |
| `/health/permissions` | Connect flow | `HealthPermissionSelectionScreen` | Live — granular groups | Pop |
| `/health/workouts` | Health overview | `HealthWorkoutsScreen` | Live | Pop |
| `/settings/connections` | Settings | `ConnectedAppsScreen` | Live — Calendar + Health + planned | Pop |
| `/settings/connections/diagnostics` | Connected Apps | `IntegrationDiagnosticsScreen` | Live — redacted ops metadata | Pop |
| `/settings/connections/lab` | Connected Apps (debug) | `IntegrationLabScreen` | Debug only | Pop |
| `/privacy` | Drawer / Settings | `PrivacyDataCenterScreen` | Live — data inventory | Pop |
| `/privacy/export` | Privacy | `DataExportScreen` | Live — local JSON export | Pop |
| `/privacy/delete` | Privacy | `DataDeletionScreen` | Live — scoped wipe | Pop |
| `/privacy/ai` | Privacy | `AiDataUseScreen` | Live — AI boundaries | Pop |
| `/security` | Drawer / Settings | `SecurityScreen` | Live — demo-auth truthful | Pop |
| `/support` | Drawer / Settings | `HelpSupportScreen` | Live — offline FAQ | Pop |
| `/support/article/:id` | Help search | Article detail | Live | Pop |
| `/support/contact` | Help | Contact form | Live — mailto/share | Pop |
| `/support/report` | Help | Report problem | Live — redacted | Pop |
| `/support/feature` | Help | Feature request | Live — share | Pop |
| `/legal` | Drawer / Settings | `LegalCenterScreen` | Live — draft docs | Pop |
| `/legal/:documentType` | Legal | Markdown viewer | Live — draft status | Pop |
| `/about` | Drawer / Settings | `AboutMeMyScreen` | Live — PackageInfo | Pop |
| `/about/whats-new` | About | What’s New | Live — changelog | Pop |
| `/settings/notifications` | Drawer / Settings | Notifications | Planned (honest) | Pop |
| `/settings/accessibility` | Drawer / Settings | Appearance | Live — theme System/Light | Pop |
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
| Quick Add → Add Event | `/calendar/new` live form | Wired |
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
