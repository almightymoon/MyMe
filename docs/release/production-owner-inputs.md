# Production owner inputs

**Status:** Incomplete. None of these values are confirmed in the repository. Do not invent them.

Fill this list before claiming live Google/Apple login, TLS, or VPS deploy succeeded.

## Domain and VPS

| Input | Status |
| --- | --- |
| Production domain | Not confirmed |
| API hostname (`api.<domain>`) | Not confirmed |
| WWW hostname | Not confirmed |
| VPS IP | Not confirmed |
| SSH access / deploy key | Not confirmed |
| DNS access | Not confirmed |
| Hosting region (for privacy copy) | Not confirmed |

## Google

| Input | Status |
| --- | --- |
| Google Cloud project | Not confirmed |
| Android OAuth client ID | Not confirmed |
| iOS OAuth client ID | Not confirmed |
| Backend web client ID (token audience) | Not confirmed |
| Android SHA-1 / SHA-256 fingerprints | Not confirmed |

## Apple

| Input | Status |
| --- | --- |
| Apple Developer Team ID | Not confirmed |
| Bundle ID | Not confirmed (current Xcode project uses the Flutter default until store setup) |
| Services ID (if used) | Not confirmed |
| Key ID | Not confirmed |
| Apple private key (`.p8`, never commit) | Not confirmed |
| Sign in with Apple capability on the App ID | Not confirmed |

## Secrets (env files outside Git)

| Input | Status |
| --- | --- |
| `DATABASE_URL` production password | Not confirmed |
| JWT access-token signing keys | Not confirmed |
| Refresh-token hash pepper | Not confirmed |
| Object-storage endpoint / keys / bucket | Not confirmed |
| Support email | Not confirmed (`SUPPORT_EMAIL` dart-define currently empty by default) |
| Backup destination | Not confirmed |

## Legal and stores

| Input | Status |
| --- | --- |
| Counsel-approved Privacy Policy URL | Not confirmed — in-app markdown is draft |
| Counsel-approved Terms URL | Not confirmed |
| App Store Connect privacy / Sign in with Apple | Not confirmed |
| Play Console Data Safety | Not confirmed |

## How to supply

Place production values in a host env file such as `/etc/memy/api.env` (not in git).  
Local/staging copies use `apps/api/.env` which is gitignored.

See `docs/architecture/production-auth-offline-sync.md`.
