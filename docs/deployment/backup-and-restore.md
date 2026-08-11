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
STAMP=$(date -u +%Y%m%d)
DIR=/var/backups/memy/$STAMP
mkdir -p "$DIR"
docker compose -f docker-compose.production.yml exec -T postgres \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$DIR/postgres.sql.gz"
# Object storage: copy the MinIO volume or `mc mirror` to an off-server bucket.
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
