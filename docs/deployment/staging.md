# Staging VPS

Staging must use a separate API hostname, PostgreSQL database, MinIO bucket, JWT secrets, and OAuth clients from production. Do not copy production user data.

## Server files

Copy examples from the repository:

- `deploy/env/compose.staging.example` → `/etc/memy/staging.env`
- `deploy/env/api.staging.example` → `/etc/memy/staging/api.env`
- `deploy/env/postgres.staging.example` → `/etc/memy/staging/postgres.env`
- `deploy/env/minio.staging.example` → `/etc/memy/staging/minio.env`

## Deploy

```bash
./scripts/deploy.sh staging
```

Or manually:

```bash
docker compose -f docker-compose.staging.yml --env-file /etc/memy/staging.env up -d --build
./scripts/migrate.sh staging
./scripts/health-check.sh staging
```

## Verify

1. `curl -f https://<staging-api-host>/api/v1/health`
2. PostgreSQL is not published (`docker compose ps` shows no 5432 on the host)
3. MinIO console is not published
4. Auth smoke: staging Google / Apple client
5. Sync smoke: push a goal, pull with a string cursor
6. Wardrobe smoke: upload one image, download via presigned URL

Mobile dart-defines: `docs/deployment/mobile-connection.md`.

The GitHub `deploy-vps.yml` workflow publishes product branches then SSHs to the VPS (secrets `IP`, `USERNAME`, `SSH_PRIVATE_KEY`, same as MyShelf). Do not claim a live deploy until those secrets exist and a run succeeds.
