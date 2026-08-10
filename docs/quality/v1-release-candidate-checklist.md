# v1 Release Candidate Checklist

MeMy **1.0.0+1** release-candidate gate. Be truthful: do not check items that were not verified.

## Engineering (code freeze)

- [x] Production configuration forces local Goals/Finance/Habits, system Calendar/Health, `AUTH_MODE=none`
- [x] No Integration Lab / Coach Preview / demo seed in production capabilities
- [x] `STORE_SCREENSHOT_MODE` internal-only; forced off in production
- [x] Feature-freeze blockers from earlier audit marked resolved in `docs/quality/v1-release-blockers.md`
- [ ] Remote CI green on release commit — **not verified in this session**

## Owner / legal / store (blocking submit)

- [ ] Legal review of Draft Privacy / Terms / Health / Financial docs
- [ ] Hosted Privacy Policy URL
- [ ] `SUPPORT_EMAIL` set for production builds
- [ ] Play upload keystore (not debug) + App Signing
- [ ] iOS distribution signing + App Store Connect record
- [ ] Export compliance confirmed with counsel
- [ ] Physical iOS smoke matrix executed
- [ ] Physical Android smoke matrix executed
- [ ] Store screenshots captured
- [ ] Play Data safety + content rating + health declarations
- [ ] App Privacy + age rating + health declarations

## Documentation pack present

- [x] `docs/release/*` identity, build, permissions, worksheets, checklists
- [x] `docs/store/apple/*` and `docs/store/google-play/*` listing copy
- [x] `docs/public/README.md` draft hosting placeholders
- [x] `docs/quality/v1-physical-device-smoke-tests.md`
- [x] `docs/product/post-v1-backlog.md`

## Verdict

**Code P0/P1:** none open for the v1 freeze (remaining issues are owner-blocked).  
**Ship-ready for store upload:** **No** until owner actions and device QA complete.
