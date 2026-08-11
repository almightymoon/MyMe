#!/usr/bin/env bash
# Staging backup: PostgreSQL dump + MinIO mirror. Secrets come from the environment.
set -euo pipefail
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
DEST="${BACKUP_PATH:-/var/backups/memy}/$STAMP"
mkdir -p "$DEST"
docker compose -f docker-compose.production.yml exec -T postgres \
  pg_dump -U "${POSTGRES_USER:-memy}" "${POSTGRES_DB:-memy}" > "$DEST/postgres.sql"
if command -v mc >/dev/null 2>&1; then
  mc mirror "local/${OBJECT_STORAGE_BUCKET:-memy-private}" "$DEST/minio"
fi
echo "Backup written under $DEST"
