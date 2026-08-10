# Google Play Data Safety Worksheet (draft answers)

Starting answers for Play Console → App content → Data safety. Owner must align with the hosted Privacy Policy. Legal review required. **No hosted privacy URL yet.**

## Overview answers (suggested)

| Question | Suggested answer | Notes |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Collects data (on-device / optional platform stores)** — refine with counsel | Goals, finance, habits local; optional calendar & health |
| Is all user data encrypted in transit? | **N/A / Yes for any HTTPS links** | Core features work offline; no MeMy sync channel |
| Do you provide a way for users to request data deletion? | **Yes** | In-app Privacy & Data deletion / wipe |
| Independent security review | **No** (unless owner later commissions one) | |

## Data types

| Data type | Collected? | Shared? | Purpose | Ephemeral? |
|---|---|---|---|---|
| Personal info (name) | Optional display name on device | No | App functionality | No |
| Financial info | Manual transactions on device | No | App functionality | No |
| Health & fitness | Read from Health Connect when granted | No (not to MoonTech) | App functionality | Session summaries; raw samples stay in Health Connect |
| Calendar | When user connects | No to MoonTech | App functionality | Device + local cache |
| App activity / diagnostics | Limited local diagnostics | No third-party analytics declared | App functionality / support | Prefer no PII |
| Device or other IDs for ads | No | No | — | — |

**Shared** means shared with third parties. Device OS health/calendar stores are platform integrations, not MeMy “sale” or ad sharing. Describe accurately in the console form.

## Not applicable for v1

- Approximate / precise location collection for product features
- Bank account linking / SMS financial scraping
- AI model training on user content via MeMy servers (none)
- Push notification tokens for marketing

## Required store fields still blocked

- [ ] Public Privacy Policy URL (owner hosts)
- [ ] Support contact / email (`SUPPORT_EMAIL` or Play Console email)
- [ ] Legal sign-off on Data safety form text
