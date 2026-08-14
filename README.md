This branch is generated from main.

Do not develop or manually commit product changes here.

Make changes on main and publish a new snapshot.

---

# MeMy mobile snapshot

| Field | Value |
| --- | --- |
| Source branch | `main` |
| Source commit | `601e3827c55f5fd8f7600f1df855d18ab7cd77f4` |
| Generated (UTC) | 2026-08-14T22:49:27Z |
| Branch | `release/mobile` |

## Flutter setup

```bash
cd apps/mobile
flutter pub get
```

### Android

```bash
cd apps/mobile
flutter run -d android
flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### iOS

```bash
cd apps/mobile
flutter run -d ios
flutter build ipa --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### API configuration

- Staging: pass `--dart-define=API_BASE_URL=https://<staging-api-host>/api/v1`
- Production: pass `--dart-define=API_BASE_URL=https://<api-host>/api/v1`

### OAuth client IDs

Configure **public** Google / Apple client IDs via dart-defines or platform config.
**No backend secret belongs in the mobile application** (no JWT keys, no DB passwords,
no MinIO credentials, no Apple private keys).
