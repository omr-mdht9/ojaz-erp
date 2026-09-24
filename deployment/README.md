# OJAZ ERP runtime deployment bundle

This directory packages the official Frappe Docker single-stack topology as an OJAZ ERP deployment reference. The stack includes MariaDB, Redis cache, Redis queue, configurator, one-time site creation, Frappe backend, nginx frontend, websocket service, short and long queue workers, and the scheduler. Persistent volumes are required for MariaDB data, Redis queue data, Frappe sites, and logs.

## Durable OJAZ image

Build the custom image from the `omr-mdht9/ojaz-erp-custom` repository:

```bash
docker build -t ghcr.io/<owner>/ojaz-erp:<tag> .
```

Set `OJAZ_IMAGE` to that image when starting the topology. Every Frappe service in `compose.ojaz-reference.yaml` accepts the variable and falls back to the upstream ERPNext image for baseline testing:

```bash
export OJAZ_IMAGE=ghcr.io/<owner>/ojaz-erp:<tag>
docker compose --env-file .env -f compose.ojaz-reference.yaml up -d
```

The image contains the OJAZ app package, Node.js, the Python editable install, and direct static asset links. Frappe site volumes are intentionally populated at runtime; after site creation, run the OJAZ installation script against the target site.

## Bring-up sequence

1. Create strong secrets outside source control and provide `MARIADB_ROOT_PASSWORD` and `SITE_ADMIN_PASSWORD` to Compose.
2. Build and publish the durable OJAZ image, then set `OJAZ_IMAGE`.
3. Start the stack with `docker compose --env-file .env -f compose.ojaz-reference.yaml up -d`.
4. Wait for configurator and create-site to complete.
5. Run `scripts/install_ojaz_app.sh` from inside the Frappe runtime with `SITE_NAME` set, or use the runtime app-install procedure documented in the custom-app repository.
6. Run `scripts/link_ojaz_assets.sh` in each frontend/runtime container when using a prebuilt site volume that predates the image.
7. Verify the frontend, websocket, queue workers, scheduler, MariaDB, Redis, and installed app health before placing a customer behind the service.

## Current hosting boundary

The connected Render workspace has only the pre-existing `nexus-erp` Docker web service and no validated MariaDB/Redis topology. Do not deploy ERPNext as a single Render web service: it would not provide a valid production runtime. Use a Docker-capable persistent host or a managed multi-service topology.

## Acceptance checks

- `bench --site <site> list-apps` includes `erpnext` and `ojaz_erp`.
- `bench --site <site> doctor` reports no blocking failures.
- The frontend loads through the configured host and returns a successful health response.
- OJAZ CSS, JavaScript, and logo URLs return HTTP 200.
- Websocket connection succeeds.
- A background job completes through both queue workers.
- Scheduler logs show a successful scheduled cycle.
- MariaDB and both Redis services pass their health checks.

Stripe billing and automated tenant-site provisioning remain intentionally deferred until this baseline is deployed durably and multi-site isolation is validated.
