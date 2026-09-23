# OJAZ ERP runtime deployment bundle

This directory packages the official Frappe Docker single-stack topology as an OJAZ ERP deployment reference. It is intentionally a reference bundle until a Docker-capable host and MariaDB/Redis services are available.

## Services included

The stack includes MariaDB, Redis cache, Redis queue, configurator, one-time site creation, Frappe backend, nginx frontend, websocket service, short and long queue workers, and the scheduler. Persistent volumes are required for MariaDB data, Redis queue data, Frappe sites, and logs.

## Bring-up sequence

1. Copy `.env.example` to `.env` and replace every placeholder with generated secrets.
2. Build or select a Frappe image that contains ERPNext and the `ojaz_erp` app.
3. Start the stack with `docker compose --env-file .env -f compose.ojaz-reference.yaml up -d`.
4. Wait for configurator and create-site to complete.
5. Run `scripts/install_ojaz_app.sh` from inside the Frappe runtime with `SITE_NAME` set.
6. Verify the frontend, websocket, queue workers, scheduler, MariaDB, and Redis health before placing a customer behind the service.

## Current blocker

The current sandbox has no Docker, Docker Compose, Frappe Bench, MariaDB client, or Redis process. The connected Render workspace has only the pre-existing `nexus-erp` Docker web service and no validated MariaDB/Redis stack. Do not deploy ERPNext as a single Render web service: it would not provide a valid production runtime.

## Acceptance checks

- `bench --site <site> list-apps` includes `erpnext` and `ojaz_erp`.
- `bench --site <site> doctor` reports no blocking failures.
- The frontend loads through the configured host and returns a successful health response.
- Websocket connection succeeds.
- A background job completes through both queue workers.
- Scheduler logs show a successful scheduled cycle.
- MariaDB and both Redis services pass their health checks.
