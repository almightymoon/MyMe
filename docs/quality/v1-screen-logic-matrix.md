# v1 Screen Logic Matrix

Completion contract for every registered MeMy mobile route as of the final
application-completion pass. Production visibility assumes
`APP_ENV=production` + `AUTH_MODE=none` + `ReleaseCapabilities.production()`.

Statuses: **Complete** · **Hidden from production** · **Internal only** · **Removed**

| Route | Screen | Production visibility | Environment visibility | Data source | Provider/controller | Repository/service | Loading | Empty | Error | Retry | Offline | Permission | Primary actions | Mutation | Persistence | Cross-feature | Back | A11y | Unit | Widget | Integration | Status | Severity |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `/onboarding` | OnboardingScreen | Yes | All | Local prefs | Onboarding prefs | SharedPreferences | N/A | N/A | Yes | Yes | Local | Contextual Calendar/Health | Finish / Skip connect | Complete once | Yes | → Today | Platform | Labels | Yes | Yes | Yes | Complete | — |
| `/signin` | SignInScreen | No (redirect) | Demo auth only | Demo | — | Fake | — | — | — | — | — | — | Continue | — | — | — | — | — | Yes | Yes | — | Hidden from production | — |
| `/signup` | SignUpScreen | No (redirect) | Demo auth only | Demo | — | Fake | — | — | — | — | — | — | — | — | — | — | — | — | — | Yes | — | Hidden from production | — |
| `/forgot-password` | ForgotPasswordScreen | No (redirect) | Demo auth only | Demo | — | Fake | — | — | — | — | — | — | — | — | — | — | — | — | — | Yes | — | Hidden from production | — |
| `/today` | TodayScreen | Yes | All | Live compose + local greeting | todaySummaryProvider | Goals/Finance/Habits/Calendar/Health + displayName | Yes | Yes | Yes | Yes | Local modules OK | Health/Calendar section | Check-in, open modules, refresh Health | Check-in upsert | Yes | Plan/Habits/… | Shell | Labels | Yes | Yes | Yes | Complete | — |
| `/plan` | PlanScreen | Yes | All | Live Goals/Habits/Finance/Health/Calendar | goals/habits/finance/health/todayCalendar | Local repos + platform | Partial | Section empty copy | Partial | Via open module | Local OK | Via Health/Calendar | Open module | None on Plan | Via modules | Today | Shell | Labels | — | Yes | — | Complete | — |
| `/coach` | CoachScreen | No (redirect) | Internal/demo when AI preview on | Demo seed | coach providers | FakeCoachRepository | — | — | — | — | — | — | — | — | — | — | — | — | — | Yes | — | Hidden from production | — |
| `/more` | MoreScreen | Yes | All | Profile + honest Insights | userProfileProvider | LocalUserRepository | Yes | — | Yes | Yes | Local | — | Navigate tiles | — | Prefs | — | Shell | Labels | — | Yes | — | Complete | — |
| `/goals` | GoalsListScreen | Yes | All | Local | goalsProvider | LocalGoalRepository | Yes | Yes | Yes | Yes | Local | — | Filter/Add | Archive/delete | Yes | Today/Plan | memyBack | Labels | Yes | Yes | Yes | Complete | — |
| `/goals/new` | AddGoalScreen | Yes | All | Form | AddGoalController | LocalGoalRepository | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/goals/:id` | GoalDetailScreen | Yes | All | Local | goalById | LocalGoalRepository | Yes | Not found | Yes | Yes | Local | — | Edit/milestone/archive/delete | Confirmed | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/habits` | HabitsOverviewScreen | Yes | All | Local | habitsOverviewProvider | LocalHabitRepository | Yes | Yes | Yes | Yes | Local | — | Add/open | — | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/habits/new` | AddHabitScreen | Yes | All | Form | HabitFormController | LocalHabitRepository | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/habits/:id` | HabitDetailScreen | Yes | All | Local | habit providers | LocalHabitRepository | Yes | Not found | Yes | Yes | Local | — | Check-in/edit/pause/archive/delete | Upsert | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/habits/:id/edit` | EditHabitScreen | Yes | All | Form | HabitFormController | LocalHabitRepository | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today/Plan | Back | Labels | Yes | Yes | — | Complete | — |
| `/finance` | FinanceOverviewScreen | Yes | All | Local | finance providers | LocalFinanceRepository | Yes | Yes | Yes | Yes | Local | — | Period/Add/See all | — | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/finance/new` | AddTransactionScreen | Yes | All | Form | TransactionFormController | LocalFinanceRepository | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today/Plan | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/finance/history` | TransactionHistoryScreen | Yes | All | Local | financeTransactionsProvider | LocalFinanceRepository | Yes | Yes | Yes | Yes | Local | — | Open detail | — | Yes | — | Back | Labels | — | Yes | — | Complete | — |
| `/finance/tx/:id` | TransactionDetailScreen | Yes | All | Local | transactionById | LocalFinanceRepository | Yes | Not found | Yes | Yes | Local | — | Edit/Delete | Confirm | Yes | Today/Plan | Back | Labels | — | Yes | — | Complete | — |
| `/finance/tx/:id/edit` | EditTransactionScreen | Yes | All | Form | TransactionFormController | LocalFinanceRepository | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today/Plan | Back | Labels | — | Yes | — | Complete | — |
| `/calendar` | CalendarOverviewScreen | Yes | All | Local + device | calendar providers | LocalCalendarRepository + gateway | Yes | Yes | Yes | Yes | Local events | Connect flow | Agenda/sync/add | Sync states | Yes | Today/Connected | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/calendar/new` | AddCalendarEventScreen | Yes | All | Form | CalendarEventFormController | Local + sync service | Busy | Validation | Mapped | Re-enable | Local first | Writable calendar | Save | Dup-guard | Yes | Today | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/calendar/connect` | CalendarConnectionScreen | Yes | All | Gateway | calendar controllers | DeviceCalendarGateway | Yes | Unavailable | Yes | Yes | N/A | Request on action | Connect | Config | Yes | Connected Apps | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/calendar/connect/select` | CalendarSelectionScreen | Yes | All | Gateway | calendar config | Local config | Yes | Empty calendars | Yes | Yes | N/A | Prior grant | Save selection | Persist | Yes | Calendar/Today | Back | Labels | — | Yes | — | Complete | — |
| `/calendar/conflicts` | CalendarConflictScreen | Yes | All | Local conflicts | conflict stream | Sync service | Yes | Empty | Yes | Yes | Local | — | Resolve | Manual | Yes | Calendar | Back | Labels | — | Yes | — | Complete | — |
| `/calendar/recovery` | CalendarRecoveryScreen | Yes | All | Recovery cases | recovery provider | Sync service | Yes | Empty | Yes | Yes | Local | — | Recover actions | Guarded | Yes | Calendar | Back | Labels | — | Yes | — | Complete | — |
| `/calendar/event/:id` | CalendarEventDetailScreen | Yes | All | Local/imported | eventById | CalendarRepository | Yes | Not found | Yes | Yes | Local | — | Edit/copy/delete (rules) | Confirm | Yes | Today | Back | Labels | — | Yes | — | Complete | — |
| `/calendar/event/:id/edit` | EditCalendarEventScreen | Yes | All | MeMy-owned only | Form controller | Local + sync | Busy | Validation | Mapped | Re-enable | Local | — | Save | Dup-guard | Yes | Today | Back | Labels | — | Yes | — | Complete | — |
| `/health` | HealthOverviewScreen | Yes | All | Platform read-only | dailyHealthSummaryProvider | HealthRepository | Yes | No data | Yes | Yes | Provider unavailable | Contextual | Refresh/connect | Refresh | Config only | Today/Connected | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/health/connect` | HealthConnectionScreen | Yes | All | Platform | HealthConnectionController | HealthRepository | Yes | Unavailable | Yes | Yes | N/A | On Connect | Connect/Skip | Config | Yes | Health | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/health/permissions` | HealthPermissionsScreen | Yes | All | Groups | HealthConnectionController | HealthRepository | Yes | — | Yes | Yes | N/A | Recheck | Save groups | Persist | Yes | Health | Back | Labels | — | Yes | — | Complete | — |
| `/health/workouts` | HealthWorkoutsScreen | Yes | All | Summary workouts | dailyHealthSummaryProvider | HealthRepository | Yes | Empty | Yes | Yes | Unavailable | — | Open overview | — | Cache only | — | Back | Labels | — | Yes | — | Complete | — |
| `/exercise` | ExerciseOverviewScreen | Yes | All | Bundled catalogue | releaseCapabilities | ExerciseDemoData (static) | N/A | N/A | Asset fallback | N/A | Local | — | Browse library | None in prod | Static assets | — | Back | Semantic art | Yes | Yes | — | Complete | — |
| `/exercise/library` | ExerciseLibraryScreen | Yes | All | Bundled catalogue | — | ExerciseDemoData | N/A | Empty filter | N/A | N/A | Local | — | Detail sheet | None in prod | Static | — | Back | Labels | Yes | Yes | — | Complete | — |
| `/exercise/session` | WorkoutSessionPlaceholderScreen | No (redirect → `/exercise`) | Non-production | Placeholder | — | — | — | — | — | — | — | — | End | — | — | — | — | — | — | Yes | — | Hidden from production | — |
| `/wardrobe` | WardrobePlaceholderScreen | No (redirect) | Non-production | Placeholder | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | Hidden from production | — |
| `/body` | BodyCompositionScreen | No (redirect) | Non-production | BodySeed | — | Seed | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | Hidden from production | — |
| `/nutrition/coming-soon` | ComingSoonView | No (redirect) | Non-production | Static | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | Hidden from production | — |
| `/settings` | SettingsScreen | Yes | All | Prefs + capabilities | releaseCapabilities | Onboarding prefs | N/A | N/A | N/A | N/A | Local | — | Navigate / reset onboarding | Reset flag | Yes | Onboarding | Back | Labels | — | Yes | Yes | Complete | — |
| `/settings/connections` | ConnectedAppsScreen | Yes | All | Calendar/Health status | integration providers | Gateways + config | Yes | Unavailable | Yes | Yes | States | Not on open | Sync/Refresh/Manage | Guarded | Yes | Calendar/Health | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/settings/connections/diagnostics` | IntegrationDiagnosticsScreen | Yes | All | Allowlisted diagnostics | diagnostics providers | Typed codes only | Yes | — | Mapped | Yes | — | — | Copy sanitized | — | — | — | Back | Labels | Yes | Yes | — | Complete | — |
| `/settings/connections/lab` | IntegrationLabScreen | No | Debug/internal only | Lab | — | Fakes | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | Internal only | — |
| `/settings/notifications` | NotificationsRemindersScreen | No (redirect → `/settings`) | Never live | Roadmap card | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | Hidden from production | — |
| `/settings/accessibility` | AppearanceAccessibilityScreen | Yes | All | Theme prefs | appearance providers | Prefs | N/A | N/A | N/A | N/A | Local | — | Theme/a11y | Persist | Yes | Global theme | Back | Labels | — | Yes | — | Complete | — |
| `/profile` | ProfileScreen | Yes | All | Local prefs | displayName + avatar | OnboardingPreferences | Yes | Defaults | Yes | Yes | Local | — | Edit / shortcuts | Prefs | Yes | Today greeting | Back | Labels | — | Yes | — | Complete | — |
| `/profile/edit` | EditProfileScreen | Yes | All | Local prefs | EditProfileController | OnboardingPreferences | Busy | Val | Y | Re | Local | — | Name + avatar catalog | Persist | Yes | Chrome avatar | Back | Labels | — | Yes | — | Complete | — |
| `/privacy` | PrivacyOverviewScreen | Yes | All | Capability registry | trust providers | DataModuleRegistry | Yes | — | Yes | Yes | Local | Module | Manage links | — | Truthful | — | Back | Labels | Yes | Yes | — | Complete | — |
| `/privacy/export` | ExportScreen | Yes | All | Local modules | export controller | Export service | Busy | Module empty | Mapped | Re-enable | Local | — | Preview/Share | Dup-guard | Temp file | — | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/privacy/delete` | DeletionScreen | Yes | All | Scoped plans | deletion controller | Deletion service | Busy | Preview | Mapped | Retry scopes | Local | — | Typed confirm | Dup-guard | Yes | All modules | Back | Labels | Yes | Yes | Yes | Complete | — |
| `/privacy/ai` | AiDataUseScreen | Yes | All | Static truthful | — | Assets/copy | N/A | N/A | Fallback | — | Local | — | Links | — | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/security` | SecurityScreen | Yes | All | Truthful static | — | Copy | N/A | N/A | — | — | Local | — | Shortcuts | — | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/support` | HelpCenterScreen | Yes | All | Offline articles | support providers | Asset markdown | Yes | No results | Yes | Yes | Offline | — | Search/open | — | Assets | — | Back | Labels | Yes | Yes | — | Complete | — |
| `/support/article/:id` | HelpArticleScreen | Yes | All | Asset | support providers | Markdown | Yes | Missing | Fallback | — | Offline | — | Related links | — | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/support/contact` | ContactSupportScreen | Yes | All | SUPPORT_EMAIL | config | url_launcher/share | Busy | Missing config | Mapped | Re-enable | Offline draft | — | Email/share | No false sent | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/support/report` | ReportProblemScreen | Yes | All | User text + redacted diag | support | Share | Busy | Validation | Mapped | Re-enable | Offline | — | Share | Dup-guard | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/support/feature` | FeatureRequestScreen | Yes | All | User text | support | Share | Busy | Validation | Mapped | Re-enable | Offline | — | Share | Dup-guard | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/legal` | LegalIndexScreen | Yes | All | Asset index | legal providers | Assets | Yes | — | Fallback | — | Offline | — | Open docs | — | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/legal/:type` | LegalDocumentScreen | Yes | All | Markdown asset | legal providers | Assets | Yes | Missing | Fallback | — | Offline | — | Links | — | — | — | Back | Labels | Yes | Yes | — | Complete | — |
| `/about` | AboutScreen | Yes | All | PackageInfo | appInfoProvider | package_info | Yes | — | Fallback | — | Offline | — | Legal/support/whats-new | — | — | — | Back | Labels | — | Yes | — | Complete | — |
| `/about/whats-new` | WhatsNewScreen | Yes | All | Asset changelog | — | whats-new.md | Yes | — | Fallback | — | Offline | — | — | — | — | — | Back | Labels | — | Yes | — | Complete | — |

## Production summary

- Registered routes: **60** named destinations (including parameterized templates).
- Production-reachable: **48** (parameterized templates counted once each).
- Hidden / redirected in production: demo auth (3), Coach, Wardrobe, Body, Nutrition, Workout session, Notifications, Integration Lab.
- Incomplete production routes: **0**.
- Open code P0/P1 against this matrix: **0** after the honesty pass (Plan live Health/Calendar, local greeting, Start Workout hidden).

## Screen completion contract (reminder)

A production screen is complete only when route open, deep link, back, provider data, valid production source, loading/empty/error/retry (as applicable), working actions, validation, dup-submit protection, reactive updates, persistence, safe errors, and a11y basics are covered — or, for static Legal/About, content load + fallback + navigation + a11y.
