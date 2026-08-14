# Google Play Submission Checklist

App: **MeMy** (`com.moontech.memy`) · Version **1.0.0 (1)**

## Binary

- [ ] Production AAB built with `APP_ENV=production` and `AUTH_MODE=none`
- [ ] **Upload keystore is not the debug keystore** (owner must create Play App Signing key)
- [ ] `SUPPORT_EMAIL` dart-define set if Play contact should match in-app mailto
- [ ] `targetSdk`/`compileSdk` 36 (Flutter default), `minSdk` 26
- [ ] Local `flutter analyze` / `flutter test` considered; **remote CI not verified in this session**

## Store listing

- [ ] App name / short / full description from `docs/store/google-play/`
- [ ] Feature graphic + 512 icon from `apps/mobile/assets/branding/store/`
- [ ] Screenshots for phone (and tablet if claiming): Today, Goals, Finance, Habits, Calendar, Health, Privacy
- [ ] Copy follows local-first rules (no AI / cloud / bank / medical / notifications claims)

## Policy forms

- [ ] Privacy Policy **URL** live (owner hosts — none yet)
- [ ] Data safety form completed (`docs/release/google-play-data-safety-worksheet.md`)
- [ ] Content rating questionnaire completed
- [ ] Health Connect / health data declarations completed
- [ ] Draft legal reviewed by owner/counsel

## Device QA (owner)

- [ ] Physical Android 14+ smoke matrix executed (`docs/quality/v1-physical-device-smoke-tests.md`)
- [ ] Health Connect permission only after Connect
- [ ] Calendar permission only after Connect
- [ ] Export / deletion verified on device

## Do not submit until

Owner-blocked items in `docs/release/owner-actions.md` and `docs/quality/v1-release-blockers.md` are cleared. There are **no open code P0/P1** called out in the blockers doc for this freeze — remaining work is owner/legal/store/signing/QA.
