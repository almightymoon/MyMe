# Owner Actions (before store submit)

Engineering freeze for MeMy v1 treats remaining ship work as **owner-blocked**, not open code P0/P1. Track status here.

## Legal & policy

| # | Action | Status |
|---|---|---|
| L1 | Legal counsel review of Privacy Policy, Terms, Health disclaimer, Financial disclaimer (currently **Draft**) | Open |
| L2 | Host public Privacy Policy (and Terms) URL — **none hosted yet** | Open |
| L3 | Confirm Apple export-compliance / `ITSAppUsesNonExemptEncryption=false` assumption | Open |
| L4 | Finalize App Privacy + Play Data safety answers with counsel | Open |

## Store & support

| # | Action | Status |
|---|---|---|
| S1 | Set production `SUPPORT_EMAIL` (empty by default) | Open |
| S2 | Create Play / App Store listings; paste copy from `docs/store/` | Open |
| S3 | Capture screenshot set (Today, Goals, Finance, Habits, Calendar, Health, Privacy) | Open |
| S4 | Complete age / content rating questionnaires | Open |
| S5 | Complete Health Connect / HealthKit store declarations | Open |

## Signing & release engineering

| # | Action | Status |
|---|---|---|
| R1 | Create Play App Signing upload keystore; stop using debug signing for release AAB | Open |
| R2 | Configure iOS distribution certs / profiles / App Store Connect app record | Open |
| R3 | Confirm remote CI green on the release commit (**not verified in this session**) | Open |

## Physical device QA

| # | Action | Status |
|---|---|---|
| Q1 | Execute iOS physical smoke matrix | Open — matrix empty / not executed |
| Q2 | Execute Android 14+ physical smoke matrix (Health Connect) | Open — matrix empty / not executed |
| Q3 | On-device export + deletion verification | Open |

## Explicitly not claimed

- Physical device tests passed
- Remote CI passed
- Store URLs live
- Production signing ready for Play upload

When all rows above are Done, proceed with `docs/quality/v1-release-candidate-checklist.md`.
