This branch is generated from main.

Do not develop or manually commit product changes here.

Make changes on main and publish a new snapshot.

---

# MeMy backend snapshot

| Field | Value |
| --- | --- |
| Source branch | `main` |
| Source commit | `81b079589e01af0bbbc29a8c528c0eddb8fe7cc8` |
| Generated (UTC) | 2026-08-17T18:00:30Z |
| Branch | `deploy/backend` |

## VPS requirements

- Docker + Docker Compose
- Host env files under `/etc/memy/` (see `deploy/env/`)
- Separate website clone at `/opt/memy/website` (do not put website source here)

## Required environment files

See `deploy/env/README.md`. Never commit filled copies.

## Staging

```bash
./scripts/deploy.sh staging
```

## Production

```bash
./scripts/deploy.sh production
```

## Database migrations

```bash
./scripts/migrate.sh staging
./scripts/migrate.sh production
```

## MinIO

Initialize buckets/credentials via the MinIO env files on the VPS.
Do not expose MinIO ports publicly.

## Backup / restore

```bash
./scripts/backup.sh production
./scripts/backup-staging.sh
```

## Health verification

```bash
./scripts/health-check.sh staging
./scripts/health-check.sh production
```

## Website clone integration

Set `MEMY_WEBSITE_ROOT` to the public site directory from the website clone, for example:

```bash
export MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
```

Compose mounts that path read-only into Caddy as `/srv/www`.
