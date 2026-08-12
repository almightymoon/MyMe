# VPS owner inputs (Staging + Production)

Copy/paste and fill the *Value* fields with the actual owner-provided data.
Do **not** add any secrets to Git; this file is intended to be owner-edited.

## How to read this document

Each input is marked with one or more of:

- **Required before staging**
- **Required before production**
- **Owner-only**
- **Current status** (left as `TBD` until you fill it)

## VPS

| Field | Value | Needed | Current status |
|---|---|---|---|
| VPS public IP | `TBD` | Required before staging + production | TBD |
| Linux distribution and version | `TBD` | Required before staging + production | TBD |
| SSH username | `TBD` | Required before staging + production | TBD |
| Whether `sudo` is available | `TBD` | Required before staging + production | TBD |
| SSH public-key access | `TBD` | Required before staging + production (owner-only) | TBD |
| Minimum RAM | `TBD` | Required before staging + production | TBD |
| Available disk | `TBD` | Required before staging + production | TBD |
| Firewall access (allowed inbound sources / ranges) | `TBD` | Required before staging + production | TBD |

## DNS

| Field | Value | Needed | Current status |
|---|---|---|---|
| Production root domain | `TBD` | Required before production | TBD |
| Production API hostname | `TBD` | Required before production | TBD |
| Production website hostname | `TBD` | Required before production | TBD |
| Staging API hostname | `TBD` | Required before staging | TBD |
| Staging website hostname | `TBD` | Required before staging | TBD |
| DNS-provider access (which account / how to authenticate) | `TBD` | Required before staging + production (owner-only) | TBD |

## Authentication (OAuth)

| Field | Value | Needed | Current status |
|---|---|---|---|
| Google backend / Web client ID | `TBD` | Required before staging + production | TBD |
| Google Android client ID | `TBD` | Required before staging + production | TBD |
| Google iOS client ID | `TBD` | Required before staging + production | TBD |
| Android SHA-1 fingerprint | `TBD` | Required before staging + production | TBD |
| Android SHA-256 fingerprint | `TBD` | Required before staging + production | TBD |
| Apple Team ID | `TBD` | Required before staging + production | TBD |
| Apple bundle identifier | `TBD` | Required before staging + production | TBD |
| Apple Service ID (where required by sign-in with Apple config) | `TBD` | Required before staging + production | TBD |
| Apple Key ID | `TBD` | Required before staging + production | TBD |
| Apple private key location (owner path, not contents) | `TBD` | Required before staging + production (owner-only) | TBD |

## Security / Secrets (owner-only)

| Field | Value | Needed | Current status |
|---|---|---|---|
| PostgreSQL production password | `TBD` | Required before production (owner-only) | TBD |
| PostgreSQL staging password | `TBD` | Required before staging (owner-only) | TBD |
| JWT access-token secret / signing keys | `TBD` | Required before staging + production (owner-only) | TBD |
| Refresh-token pepper | `TBD` | Required before staging + production (owner-only) | TBD |
| MinIO access key | `TBD` | Required before staging + production (owner-only) | TBD |
| MinIO secret key | `TBD` | Required before staging + production (owner-only) | TBD |
| GitHub deployment SSH key | `TBD` | Required before staging + production (owner-only) | TBD |
| Container-registry credentials (when used) | `TBD` | Required before staging + production (owner-only) | TBD |

## Operations

| Field | Value | Needed | Current status |
|---|---|---|---|
| Backup destination | `TBD` | Required before staging + production (owner-only) | TBD |
| Backup retention | `TBD` | Required before staging + production (owner-only) | TBD |
| Support email | `TBD` | Required before staging + production | TBD |
| Privacy-policy URL | `TBD` | Required before staging + production | TBD |
| Terms URL | `TBD` | Required before staging + production | TBD |

