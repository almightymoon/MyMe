# App Store Submission Checklist

App: **MeMy** (`com.moontech.memy`) · Version **1.0.0 (1)**

## Binary

- [ ] Production IPA / archive with `APP_ENV=production` and `AUTH_MODE=none`
- [ ] Distribution signing / provisioning configured (owner)
- [ ] HealthKit capability on App ID
- [ ] Deployment target 14.0+
- [ ] `SUPPORT_EMAIL` set if desired for review contact consistency
- [ ] Export compliance answer matches legal review of `ITSAppUsesNonExemptEncryption`
- [ ] Local analyze/tests considered; **remote CI not verified in this session**

## App Store Connect listing

- [ ] Name, subtitle, description, keywords, promotional text from `docs/store/apple/`
- [ ] What’s New from `release-notes-1.0.0.txt`
- [ ] 1024 icon from store branding masters
- [ ] Screenshots: Today, Goals, Finance, Habits, Calendar, Health, Privacy
- [ ] Review notes from `review-notes.txt`
- [ ] Privacy Policy URL live (owner hosts — none yet)
- [ ] Age rating questionnaire completed
- [ ] App Privacy nutrition labels completed with counsel

## Health & calendar

- [ ] Review notes explain delayed permission prompts and read-only Health
- [ ] Usage strings present; no Health write string

## Device QA (owner)

- [ ] Physical iOS smoke matrix executed
- [ ] HealthKit / EventKit prompts only after Connect
- [ ] Export / deletion verified on device

## Do not submit until

Owner-blocked items in `docs/release/owner-actions.md` are cleared.
