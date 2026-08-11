# Staging VPS

Staging must use a separate API hostname, PostgreSQL database, MinIO bucket, JWT secrets, and OAuth clients from production. Do not copy production user data.

## Start

```bash
docker compose -f docker-compose.production.yml --env-file /etc/memy/staging.env up -d --build
```

## Verify

1. `curl -f https://<staging-api-host>/api/v1/health`
2. PostgreSQL is not published (`docker compose ps` shows no 5432 on the host)
3. MinIO console is not published
4. `npx prisma migrate deploy` from the API container
5. Auth smoke: mocked or owner Google staging client
6. Sync smoke: push a goal, pull with a string cursor

The GitHub `deploy-production.yml` workflow is `workflow_dispatch` only. Do not claim a live deploy until owner SSH and environment secrets exist and a run succeeds.
