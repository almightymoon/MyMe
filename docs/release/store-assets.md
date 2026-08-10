# Store Assets

## Icons & graphics (repo)

See `docs/release/branding-assets.md`. Files under `apps/mobile/assets/branding/store/`:

- `app-icon-1024.png`
- `play-icon-512.png`
- `play-feature-graphic-1024x500.png`
- `adaptive-foreground-1024.png`
- `adaptive-background-1024.png`

## Listing copy (repo)

| Store | Path |
|---|---|
| Apple | `docs/store/apple/*.txt` |
| Google Play | `docs/store/google-play/*.txt` |

## Screenshot story (document only — capture not completed in this pack)

Capture from a **production-shaped** or approved **internal screenshot-mode** build. Suggested ordered set:

1. **Today** — daily companion home
2. **Goals** — local goals / milestones
3. **Finance** — manual transactions (no bank sync)
4. **Habits** — check-ins / streaks
5. **Calendar** — device calendar schedule
6. **Health** — read-only wellness dashboard
7. **Privacy** — Privacy & Data centre (local control)

### Capture modes

| Mode | When to use |
|---|---|
| Production (`APP_ENV=production`) | Real empty-first-run / owner device data |
| Internal screenshot mode | `APP_ENV=internal` + `STORE_SCREENSHOT_MODE=true` for deterministic fake Calendar/Health — **never** in production |

Physical screenshot pass status: **not executed** in the session that authored this pack. Track in `docs/quality/v1-physical-device-smoke-tests.md`.

## Copy rules (enforce in listings)

- No live AI claims
- No cloud sync / MeMy account claims
- No bank sync claims
- No medical diagnosis / treatment claims
- No notification / reminder claims
- Emphasize local-first and optional system Calendar / Health
