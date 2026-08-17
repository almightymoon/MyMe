# VPS production deployment

Do not put SSH keys, database passwords, or OAuth secrets in this file.

## What must not be deployed publicly

- `/prototype/web` HTML prototype
- `/reference images`
- Internal screenshot mode
- Debug API docs in production if the owner disables them
- PostgreSQL and MinIO ports

The public website is `/apps/www` (landing, privacy, terms, support).
On a dual-clone VPS, serve it from `/opt/memy/website/apps/www` via
`MEMY_WEBSITE_ROOT` (see `docs/deployment/product-branch-workflow.md`).

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
2. Place env files (see `deploy/env/README.md` and `deploy/env/compose.production.example`).
   Production API startup fails without JWT, refresh pepper, HTTPS `API_PUBLIC_URL`,
   and object-storage settings.
3. Shared Apache VPS: `/opt/memy/backend/scripts/vps-apache-deploy.sh`
   (GitHub Actions: `.github/workflows/deploy-vps.yml`).
   Dedicated Caddy host: `./scripts/deploy.sh production`
4. Check `https://memy.athariqbal.com` and `https://api.memy.athariqbal.com/api/v1/health`
   Admin: `https://memy.athariqbal.com/admin/` (operator login, not Google).
5. If the new API image fails health, roll back the **application image only**.
   Never automatically roll back a destructive database migration.

## Rollback

Retag and start the previous `MEMY_API_IMAGE`. Leave the database at the applied migration.

## Logs

`docker compose -f docker-compose.production.yml logs -f api`
