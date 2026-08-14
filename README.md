This branch is generated from main.

Do not develop or manually commit product changes here.

Make changes on main and publish a new snapshot.

---

# MeMy website snapshot

| Field | Value |
| --- | --- |
| Source branch | `main` |
| Source commit | `bf484f8f53f14feafe7cafccf80c7cbf3fdc494e` |
| Generated (UTC) | 2026-08-14T23:27:49Z |
| Branch | `deploy/website` |

## Public website

Static files under `apps/www/`:

- Landing page (`index.html`)
- Privacy, Terms, Support
- Health and Financial disclaimer pages when present
- Assets under `apps/www/assets/`

## Local preview

```bash
cd apps/www
python3 -m http.server 8765
```

## VPS

Clone this branch to `/opt/memy/website` and point backend Compose at:

```bash
MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
```

Do not publish the interactive prototype (`prototype/web`) from this branch.
