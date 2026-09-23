# OJAZ ERP ERPNext topology plan

This plan is based on the official [`frappe/frappe_docker`](https://github.com/frappe/frappe_docker) single-compose reference. ERPNext is not a single-process web application.

## Required services

| Service | Purpose | OJAZ readiness |
|---|---|---|
| MariaDB | Primary Frappe/ERPNext database | Required; not available in the current Render workspace |
| Redis cache | Cache and transient state | Required |
| Redis queue | Background jobs and pub/sub | Required |
| Configurator | Writes shared Frappe site configuration | Required once per stack |
| Backend | Gunicorn/Frappe HTTP API | Ready to connect to the fork |
| Frontend | Nginx static asset serving and reverse proxy | Required public entry point |
| Websocket | Realtime notifications and events | Required |
| Queue workers | Short/default and long-running jobs | Required |
| Scheduler | Scheduled ERPNext jobs | Required |
| Persistent sites volume | Site files, assets, and multi-site config | Required |

## Current deployment decision

The connected Render workspace currently has only the older `nexus-erp` Docker web service. Render does not currently expose a validated MariaDB/Redis topology for this task, and this sandbox has no Docker daemon or Frappe Bench. Therefore no ERPNext service has been created or exposed under OJAZ ERP, avoiding a false-positive deployment.

The next infrastructure action is to provision a MariaDB-compatible managed database plus Redis and the Frappe service group, then run the official setup sequence and health checks before customer access is enabled. Stripe and automated site provisioning remain blocked behind this baseline validation.
