# Apple App Privacy Worksheet (draft answers)

Use these as **starting answers** in App Store Connect → App Privacy. Owner must verify against the final Privacy Policy and actual binary behavior. Legal review required.

## Product posture (v1 production)

- No MeMy account
- No MeMy cloud sync of user Goals / Finance / Habits / calendar content / health samples
- Optional device Calendar (read/write on device calendars)
- Optional HealthKit **read** of activity / heart / sleep / weight / workouts
- Local export / share via system share sheet when the user initiates it
- Optional `SUPPORT_EMAIL` mailto only when configured
- No tracking for ads; no third-party analytics SDK called out in the v1 dependency set

## Data types — suggested declarations

| Data type | Collect? | Linked to identity? | Used for tracking? | Notes |
|---|---|---|---|---|
| Contact Info (email) | No (unless user emails support outside the app) | N/A | No | App does not collect email into MeMy servers |
| Health & Fitness | **Yes — on device / HealthKit only** | No MeMy account identity | No | Read from HealthKit when user grants; not sent to MeMy backend |
| Financial Info | **Yes — user-entered transactions on device** | No | No | Manual ledger only; no bank link |
| Other User Content (goals, habits, notes) | **Yes — on device** | No | No | Local storage |
| Calendar events | **Yes — via EventKit when connected** | No | No | Device calendar; local MeMy cache |
| Diagnostics | Product / crash diagnostics if Apple system reports only | No | No | In-app diagnostics avoid personal content; no third-party crash SDK required for v1 |
| Identifiers | Device IDs for ads | **No** | No | |
| Usage Data for ads | **No** | | | |
| Purchases | **No** (no IAP in v1 scope) | | | |

## “Data not collected” vs “Data collected”

Apple distinguishes data the **developer** collects. For local-only on-device storage that never leaves the device to MoonTech servers, complete the questionnaire carefully with counsel. Typical approach for local-first apps:

- Declare Health / financial / user content as collected **only if** your counsel treats on-device processing as “collection,” **or** follow Apple’s latest guidance for on-device-only processing.
- Be consistent with the hosted Privacy Policy.
- Do **not** claim “Data Not Collected” if you also declare HealthKit usage without a matching narrative.

**This worksheet does not invent a final App Privacy nutrition label.** Owner + counsel must click through App Store Connect with the hosted policy URL.

## Tracking

Answer **No** to tracking unless a future SDK introduces ATT-covered tracking. v1 production does not include live AI or ad networks.
