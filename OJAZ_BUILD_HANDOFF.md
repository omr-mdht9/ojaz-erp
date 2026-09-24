# OJAZ ERP build handoff

## Current status

The OJAZ ERP control plane is running as a responsive WebDev application with a branded overview dashboard, tenant/workspace registry, billing data model, deployment registry, workspace provisioning UI, tenant detail drawer, and deployment-health modal. The current control-plane checkpoint is `862008fa`. Its automated validation passes 7 tests, TypeScript checks, and a production build.

The official ERPNext fork is available at `omr-mdht9/ojaz-erp`, tracking the upstream `frappe/erpnext` `develop` branch. The fork retains the upstream GPL-3.0 license and core source. OJAZ-specific runtime customizations are isolated in the private `omr-mdht9/ojaz-erp-custom` Frappe app repository.

## Build history

1. **Specification review.** The project brief selected ERPNext/Frappe as the hosted SaaS foundation, required isolated Frappe sites per customer, rebranding, browser-only access, Render deployment, and deferred Stripe billing and automated provisioning until later.
2. **Control-plane scaffold.** A full-stack OJAZ control-plane WebDev project was initialized with React, Express, tRPC, Drizzle/MySQL, object storage, and Manus authentication.
3. **Domain model.** Tenant, plan, subscription, and deployment tables were added and migrated. Tenant overview, billing snapshot, and protected tenant provisioning procedures were implemented.
4. **Branding.** The project was rebranded from the initial working name to OJAZ ERP. The supplied logo was uploaded to private project storage and integrated into the control-plane sidebar. Metadata and workspace domain copy were updated to `ojazerp.app`.
5. **Dashboard hardening.** Workspace search, status filters, refresh behavior, responsive navigation, accessible modal dismissal, and regression tests were added.
6. **GitHub baseline.** The GitHub account `omr-mdht9` was inspected. The empty `ERP-NEW` repository and unrelated `nexus-erp` project were not reused as the ERPNext foundation. A proper public fork was created at `omr-mdht9/ojaz-erp` from `frappe/erpnext`.
7. **Custom app boundary.** The private `omr-mdht9/ojaz-erp-custom` repository was created with OJAZ hooks, metadata, CSS/JS, the supplied logo, installation guidance, a structure validator, and an installation script. ERPNext core was not modified for branding.
8. **Deployment planning.** The official `frappe/frappe_docker` topology was inspected. The OJAZ fork now contains `deployment/ERPNext-TOPOLOGY.md`, `deployment/README.md`, and a sanitized `deployment/compose.ojaz-reference.yaml` covering MariaDB, Redis cache, Redis queue, configurator, site creation, frontend, backend, websocket, workers, and scheduler.
9. **Tenant and deployment views.** The control plane now exposes tenant detail and deployment health procedures and views backed by the deployment registry.

## Exact stopping point

The current environment does not have Docker, Docker Compose, Frappe Bench, MariaDB, or Redis. The connected Render workspace contains only the pre-existing `nexus-erp` Docker web service. No ERPNext service was created because a single Render web service cannot satisfy ERPNext's MariaDB/Redis/worker/realtime topology, and exposing a partial stack would be misleading and unsafe for customer data.

The custom app structure validator passes. The installation script is ready but intentionally exits with a clear runtime error when executed outside a Frappe Bench runtime. A real Frappe site installation and live health check have not yet been completed.

## Next steps when execution can resume

1. Provide or attach a Docker-capable persistent host, or provision a supported managed MariaDB and Redis topology alongside the application runtime.
2. Bring up the sanitized compose bundle, generate strong secrets outside source control, and complete the official Frappe site creation sequence.
3. Run `scripts/install_ojaz_app.sh` inside the Frappe runtime with `SITE_NAME` set, then verify `bench --site <site> list-apps` includes both `erpnext` and `ojaz_erp`.
4. Run live checks for HTTP, websocket, MariaDB, Redis cache, Redis queue, queue workers, scheduler, and site migrations.
5. Connect the validated deployment to the OJAZ control-plane deployment registry.
6. Only after the baseline is healthy, begin Stripe billing and automated multi-tenant site provisioning as the final phase.

## Important deferred scope

Stripe billing, per-user subscription enforcement, automated site provisioning, customer onboarding automation, and customer-facing self-service are intentionally deferred. No installer, downloadable source package, or customer-controlled self-hosted deployment should be created without a separate licensing review.

## Latest validation results

The OJAZ custom-app structure validator passed. The installation script was exercised and exited with the expected code `2` because Frappe Bench is not installed in the current environment. The existing Render `nexus-erp` health endpoint timed out with no response during the read-only check; this is not an OJAZ ERP deployment and is not being treated as a valid ERPNext health signal.

## Live runtime milestone completed

Docker and Docker Compose v2 were installed in the sandbox. The official ERPNext v16.35.0 image, MariaDB 11.8, and Redis 6.2 images were pulled successfully. The Frappe topology was started with the sandbox-compatible Docker daemon configuration. The `frontend` site was created and ERPNext was installed.

The private custom-app repository could not be cloned from inside the container without credentials, so the already-validated local app source was injected into the runtime without exposing repository credentials. The app package was corrected to use the standard nested Frappe module namespace, installed into Bench's Python environment, registered on the `frontend` site, migrated, and verified with `bench --site frontend list-apps`.

Final live checks passed: Frappe 16.34.0, ERPNext 16.35.0, and `ojaz_erp 0.1.0 main` are registered; the site scheduler is enabled; workers are online; MariaDB is healthy; Redis cache and queue are running; backend, frontend, websocket, short queue, long queue, and scheduler containers are running; the frontend returns HTTP 200; and the OJAZ CSS, JavaScript, and logo URLs each return HTTP 200. The ERPNext image does not contain Node.js, so `bench build` cannot bundle assets; the plain OJAZ assets are served through the repeatable runtime asset-link helper instead.

The next engineering phase is to make this topology durable rather than sandbox-injected: build a custom Frappe image containing the OJAZ app, Node.js, and the asset-link/build step; provision persistent managed infrastructure; connect the deployment registry; then implement Stripe billing and automated tenant provisioning as the final phase.
