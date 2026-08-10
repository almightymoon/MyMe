# Privacy Policy

**Status:** Draft (not legal counsel–approved)  
**Version:** 0.1.0  
**Effective date:** 2026-08-10  
**Product:** MeMy by MoonTech

This draft describes how the MeMy mobile app handles information in the current build. It is provided for transparency while the product is in active development. It is **not** a claim of GDPR, HIPAA, or other regulatory certification.

## What MeMy is

MeMy is a personal life OS that helps you track goals, finance, habits, calendar, and (optionally) wellness summaries from your device health platforms.

## Information MeMy stores on your device

Depending on which features you use, MeMy may store:

- **Goals** — titles, milestones, progress, and related notes (SharedPreferences). When the app is built with `GOALS_DATA_SOURCE=api`, goals may also sync to the MeMy API.
- **Finance** — manual transactions and categories. Stored on this device only in this build. Not sent to a MeMy backend or AI provider.
- **Habits** — habits and check-ins. Stored on this device only. Not sent to a MeMy backend or AI provider.
- **Calendar** — a local cache (SQLite/Drift) of MeMy events and sync metadata. Device calendars (EventKit / Android Calendar Provider) remain separate. MeMy does not upload calendar content to a MeMy backend or AI provider in this build.
- **Health** — connection and permission configuration only. Daily summaries are computed in memory for the session. Raw health samples stay in HealthKit / Health Connect. Health values are **not** sent to MeMy API or AI.
- **Preferences** — limited appearance settings when you choose them (for example theme mode or reduce motion).
- **Diagnostics** — operational counts and status codes for Connected Apps troubleshooting (never event titles or health values).

## What MeMy does not do in this build

- Does not sell personal data.
- Does not use Health data for advertising.
- Does not claim end-to-end encryption, MFA, GDPR readiness, or HIPAA compliance.
- Does not write to HealthKit / Health Connect (read-only).
- Does not delete events from your device calendars when you wipe MeMy’s local calendar cache.

## AI Coach

The AI Coach experience in this build does not receive Health samples, calendar event titles, or finance ledgers. Do not assume future AI features will share the same boundary until this policy is updated.

## Your choices

In **Privacy & Data** you can:

- Review which modules store data and where
- Export selected MeMy-owned modules as a JSON file
- Delete selected local MeMy data (goals, finance, habits, calendar cache, health connection prefs)

External stores (device calendars, HealthKit / Health Connect) are managed by your operating system and remain under your control.

## Contact

If a support email is configured for your build (`SUPPORT_EMAIL`), use Help & Support → Contact. Otherwise use in-app feedback channels provided by MoonTech.

## Changes

We will update the version and effective date when this draft changes. Continued use after a published update means you have had a chance to review the new draft.
