# NUMERA ERP production-readiness gate

This document is the handoff between free product development and the first paid infrastructure deployment. No hosting account or payment should be created until the host, region, budget, storage, backups, and exact deployment payload are approved.

## Current position

The NUMERA ERP fork contains the provider-neutral ERPNext topology in `compose.ojaz-reference.yaml`. The topology requires MariaDB, Redis cache, Redis queue, configurator, site creation, backend, frontend, websocket, scheduler, and both queue workers. The durable NUMERA image and private custom app repository are separate deployment inputs and must be supplied through an approved immutable registry reference.

The repository includes `scripts/ojaz-production-preflight.sh`. The preflight checks required variables, password length, immutable GHCR image format, Compose-file availability, and Compose syntax when Docker is available. It does not start services and does not print secret values.

## Host decision record

Complete this table before deployment:

| Decision | Approved value |
|---|---|
| Provider | Pending user approval |
| Region | Pending user approval |
| Monthly budget ceiling | Pending user approval |
| CPU / memory | Recommended starting point: 4 vCPU / 16 GB RAM |
| Durable database storage | Required |
| Sites and logs storage | Required |
| Redis cache and queue | Required |
| Backups | Daily minimum; restore test required |
| TLS and domain | Required before customer access |
| Monitoring and alerting | Required before production acceptance |
| Rollback plan | Immutable image digest plus database backup |

## Deployment payload

The approved deployment must use the private NUMERA image pinned by immutable digest, not a floating tag. Set the image and secrets in the host environment or an equivalent secret store:

```bash
export OJAZ_IMAGE='ghcr.io/<owner>/<image>@sha256:<approved-digest>'
export MARIADB_ROOT_PASSWORD='<secret from the host secret store>'
export SITE_ADMIN_PASSWORD='<secret from the host secret store>'
./scripts/ojaz-production-preflight.sh
```

Never commit passwords, API keys, provider tokens, or `.env` files.

## Acceptance sequence

1. Pull the approved image digest and record it in the deployment record.
2. Start the database and Redis services with durable volumes.
3. Run the configurator and site-creation jobs once; verify they complete successfully.
4. Start backend, frontend, websocket, scheduler, and queue workers.
5. Verify HTTPS access, Frappe login, ERPNext app registration, and NUMERA branding.
6. Verify MariaDB connectivity, Redis cache, Redis queue, scheduled jobs, websocket events, and queue execution.
7. Verify `bench --site <site> list-apps` includes `erpnext` and `ojaz_erp`.
8. Verify restart recovery without losing sites, logs, or database data.
9. Create two isolated test workspaces and prove users, data, files, and permissions cannot cross workspace boundaries.
10. Execute backup and restore tests before production acceptance.
11. Register the real runtime URL and immutable version in the control plane.
12. Run control-plane acceptance checks and explicitly approve the deployment.

## Not yet authorized

Stripe live billing, automated Frappe site provisioning, customer onboarding automation, and production customer access remain blocked until the durable runtime passes the full acceptance sequence. Link-only invitations remain the safe default until an email provider is configured.
