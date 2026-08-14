# Product branch workflow

This repository keeps **one authoritative monorepo** on `main` and publishes
three **generated snapshot branches** for deployment and sharing.

## Branches

| Branch | Purpose | Consumers |
| --- | --- | --- |
| `main` | Complete MeMy monorepo — only place for product development | Everyone developing features |
| `release/mobile` | Flutter mobile source snapshot | Mobile team / store builds |
| `deploy/backend` | NestJS API + VPS deploy stack | VPS `/opt/memy/backend` |
| `deploy/website` | Public static website only | VPS `/opt/memy/website` |

```text
Develop on main
→ review and merge to main
→ run full CI
→ publish generated branches
→ mobile team consumes release/mobile
→ VPS pulls deploy/backend and deploy/website
→ deploy staging
→ test staging
→ deploy production
```

## Important limitation (access control)

Branches are useful for **deployment separation** and **smaller clones**, but
branches inside one GitHub repository are **not** a strict access-control
boundary. A collaborator with repository access may be able to fetch all
branches.

If strict team-level source isolation is required later, mirror the generated
branches into separate repositories (for example `MeMy-Mobile`, `MeMy-Backend`,
`MeMy-Website`). Do not treat this workflow as a substitute for that split.

## Why `main` stays authoritative

- Generated branches are rebuilt from a committed `main` SHA.
- Manual edits on generated branches are discarded on the next publish.
- CI for product quality continues to run against the full monorepo.

## Markers

Every generated commit includes:

- `.memy-generated-branch` — `generated=true`, `do_not_edit=true`
- `.memy-source-commit` — exact `main` SHA used to build the snapshot
- `.memy-generated-at` — UTC timestamp (ignored for no-op change detection)

If a local or remote branch named `release/mobile`, `deploy/backend`, or
`deploy/website` exists **without** `.memy-generated-branch`, publication
**refuses to overwrite it**.

## Publishing

Dry-run is the default:

```bash
./scripts/publish-product-branches.sh --dry-run
./scripts/publish-product-branches.sh --all
./scripts/publish-product-branches.sh --mobile --commit
./scripts/publish-product-branches.sh --all --push
```

Requirements:

- Clean working tree
- Allowlists in `branch-manifests/*.txt`
- Product validation (Flutter / NestJS / website checks)
- Secret scan of the generated tree
- Fast-forward push only (`--push`); **never** force-push

Manual GitHub Action: `.github/workflows/publish-product-branches.yml`
(`workflow_dispatch` only).

### Branch protection note

If GitHub branch protection blocks updates to `deploy/*` or `release/*`, allow
the publishing GitHub App / bot to push those branches, or use a ruleset
exception for the publication workflow identity. Do not disable protection on
`main`.

## VPS layout

```text
/opt/memy/backend   ← clone of deploy/backend
/opt/memy/website   ← clone of deploy/website
```

### Clone (read-only deploy key)

```bash
git clone \
  --single-branch \
  --branch deploy/backend \
  --depth 1 \
  git@github.com:OWNER/MyMe.git \
  /opt/memy/backend

git clone \
  --single-branch \
  --branch deploy/website \
  --depth 1 \
  git@github.com:OWNER/MyMe.git \
  /opt/memy/website
```

Use a **read-only deploy key**. Do not put a personal access token in the clone URL.

The VPS must **not** clone `main` or `release/mobile`.

### Website → Caddy

Preferred static mount (already wired in Compose):

```bash
export MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
```

Compose mounts `${MEMY_WEBSITE_ROOT}:/srv/www:ro` into Caddy.
`scripts/deploy.sh` verifies the website root exists before deploying.

### Update (shared Apache VPS)

Preferred path — GitHub Actions (same secrets as MyShelf/forex: `IP`,
`USERNAME`, `SSH_PRIVATE_KEY`):

1. Push to `main` (paths under `apps/www`, `apps/api`, `deploy/`, …) **or**
   run **Deploy to Server** via `workflow_dispatch`.
2. Workflow publishes `deploy/website` + `deploy/backend`, then SSHs and runs
   `/opt/memy/backend/scripts/vps-apache-deploy.sh`.

That script pulls both clones, rebuilds the API on `127.0.0.1:4020` with the
Apache compose override (Caddy disabled), applies migrations, and refreshes
**only** `memy*` Apache vhosts. It does not edit forex/portfolio/lab configs.

Manual:

```bash
/opt/memy/backend/scripts/vps-apache-deploy.sh
# or website-only:
/opt/memy/backend/scripts/vps-apache-deploy.sh --website-only
```

On a dedicated host that uses Caddy on 80/443 (not this shared VPS):

```bash
cd /opt/memy/backend
git fetch origin deploy/backend && git reset --hard origin/deploy/backend
cd /opt/memy/website
git fetch origin deploy/website && git reset --hard origin/deploy/website
cd /opt/memy/backend
export MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
./scripts/deploy.sh production
```

Do **not** use `git reset --hard origin/main` on the VPS.
Do **not** run stock `./scripts/deploy.sh production` on the shared Apache host
(it would try to bind Caddy to 80/443).

## Rollback

Roll back by generated snapshot commit (backend and website independently when
compatible):

```bash
cd /opt/memy/backend
git log --oneline
git checkout <previous-backend-snapshot-sha>

cd /opt/memy/website
git log --oneline
git checkout <previous-website-snapshot-sha>
```

Match compatible pairs using `.memy-source-commit` when API and website must
align. Prefer reviewed tags after staging validation; this workflow does not
auto-create tags.

## Recovering a generated branch

1. Delete the broken local branch only if it still contains the generated marker
   and you intend to rebuild: `git branch -D deploy/backend`
2. Re-run `./scripts/publish-product-branches.sh --backend --commit`
3. Push with `--push` when validation passes

If the remote branch was never a generated branch, rename or remove it manually
before publishing — the script will not overwrite an unrecognized branch.

## Detecting accidental manual edits

```bash
git show deploy/backend:.memy-generated-branch
git show deploy/backend:.memy-source-commit
git log -1 --format='%s' deploy/backend
```

Expected subjects look like:

```text
chore(deploy): publish backend snapshot from <main-sha>
```

## Migrating to separate repositories later

1. Create empty `MeMy-Mobile`, `MeMy-Backend`, `MeMy-Website` repositories.
2. Push each generated branch to the matching remote as `main` (or keep the
   same branch names).
3. Point VPS remotes at the backend/website repos.
4. Keep publishing from this monorepo until the mirror is automated.

## Related paths

- Manifests: `branch-manifests/{mobile,backend,website}.txt`
- Publisher: `scripts/publish-product-branches.sh`
- Secret scan: `scripts/scan-generated-secrets.sh`
- Website checks: `scripts/validate-website-content.sh`
- Production site on `main`: `apps/www`
- Prototype (not public): `prototype/web`
