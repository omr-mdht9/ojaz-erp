# OJAZ ERP deployment boundary

This repository is the OJAZ ERP fork of [`frappe/erpnext`](https://github.com/frappe/erpnext), currently tracking the upstream `develop` branch. The upstream GPL-3.0 license and notices remain intact.

OJAZ-specific branding and future SaaS integration must be implemented in the separate [`ojaz-erp-custom`](https://github.com/omr-mdht9/ojaz-erp-custom) Frappe app, not by editing ERPNext core files.

## Baseline deployment requirement

A usable Frappe/ERPNext deployment requires more than the application web process: MariaDB, Redis, background workers, scheduler, and realtime/socket services must be available and tested together. The current Render workspace contains an existing Docker web service for the older `nexus-erp` project, but no validated MariaDB/Redis topology for this ERPNext fork. OJAZ ERP will not expose customer data or claim a working ERPNext baseline until that dependency topology is provisioned and health-checked.

Stripe billing and automated multi-tenant site provisioning are intentionally deferred until after the baseline runtime and branding app are validated.
