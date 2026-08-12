# Backup and restore

A backup is not valid until restore has been rehearsed.

## What to back up

- PostgreSQL (`pg_dump`)
- MinIO / private object-storage volume
- Non-secret configuration metadata (hostnames, bucket names)

Do not back up Health platform data. It is never uploaded.

Do not commit backup files.

## Daily dump (example)

Run on the VPS, not from developer laptops:

```bash
#!/usr/bin/env bash
set -euo pipefail
ENVIRONMENT="${1:-production}"
STAMP=$(date -u +%Y%m%d)
DIR=/var/backups/memy-${ENVIRONMENT}/$STAMP
mkdir -p "$DIR"
./scripts/backup.sh "$ENVIRONMENT"
```

Retention and off-server encryption are owner configuration.

## Restore test

1. Restore into a **staging** database, never production-in-place on first try.
2. `prisma migrate status` on the restored schema.
3. Start API against the restored URL.
4. Sign in with a staging Google client.
5. Confirm one wardrobe object can be downloaded.

## Health data

Apple Health and Health Connect records remain on devices and are not in these backups.
