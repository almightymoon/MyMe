# VPS production deployment

Do not put SSH keys, database passwords, or OAuth secrets in this file.

## What must not be deployed publicly

- `/app` HTML prototype
- `/reference images`
- Internal screenshot mode
- Debug API docs in production if the owner disables them
- PostgreSQL and MinIO ports

The public website is `/apps/www` (landing, privacy, terms, support).

## Prerequisites

- Ubuntu (or similar) VPS with Docker and Docker Compose
- DNS for the confirmed www and API hostnames
- Firewall allowing 22, 80, and 443 only
- Files on the server:
  - `/etc/memy/api.env`
  - `/etc/memy/postgres.env`
  - `/etc/memy/minio.env`

## Process

1. Copy the release image or build `apps/api/Dockerfile`.
2. Place env files. Production API startup fails without JWT and refresh secrets.
3. `docker compose -f docker-compose.production.yml up -d`
4. Run Prisma migrations inside the API container:
   `docker compose -f docker-compose.production.yml exec api npx prisma migrate deploy`
5. Check `https://<api-host>/api/v1/health`
6. If the new API image fails health, roll back the **application image only**. Never automatically roll back a destructive database migration.

## Rollback

Retag and start the previous `MEMY_API_IMAGE`. Leave the database at the applied migration.

## Logs

`docker compose -f docker-compose.production.yml logs -f api`
