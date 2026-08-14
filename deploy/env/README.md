# VPS environment files (outside Git)

Place real secrets on the server only. Copy the `*.example` files in this
directory and fill values on the VPS.

## Staging layout

```
/etc/memy/staging.env                 # compose hostnames + image tag
/etc/memy/staging/api.env             # NestJS runtime
/etc/memy/staging/postgres.env        # PostgreSQL bootstrap
/etc/memy/staging/minio.env           # MinIO root credentials
```

## Production layout

```
/etc/memy/production.env              # compose hostnames + image tag
/etc/memy/production/api.env          # NestJS runtime (or /etc/memy/api.env)
/etc/memy/production/postgres.env     # PostgreSQL bootstrap
/etc/memy/production/minio.env        # MinIO root credentials
```

`docker-compose.production.yml` currently reads `/etc/memy/api.env` for the API
and `/etc/memy/postgres.env` / `/etc/memy/minio.env` for infrastructure. When
migrating to the nested layout, update the `env_file` paths in the compose file
or symlink the files.

Never commit filled copies. Rotate JWT, refresh pepper, and database passwords
independently between staging and production.
