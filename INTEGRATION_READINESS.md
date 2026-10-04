# NUMERA ERP integration readiness contract

**Status:** Development preparation only. No paid plan, subscription, account creation, external deployment, billing, email sending, or customer access is authorized by this file.

This contract defines what NUMERA will need later while keeping the current build safe and free.

## 1. Docker-capable persistent hosting

The production ERPNext runtime requires a persistent Docker host or an equivalent multi-service platform. The host must support the complete topology in `compose.ojaz-reference.yaml`:

- MariaDB
- Redis cache and Redis queue
- Frappe configurator and one-time site creation
- Backend and frontend
- Websocket service
- Scheduler and queue workers
- Durable storage for database data, sites, files, queue data, and logs

**Current state:** design and local validation only. Do not create a hosting account or start a paid instance. The target baseline remains 4 vCPU, 16 GB RAM, and at least 100 GB durable SSD/NVMe storage, subject to final workload testing.

## 2. Domain and DNS

A customer-facing deployment will need a domain with:

- DNS control for the NUMERA control plane and ERP runtime
- TLS certificates, preferably automated through the selected host or reverse proxy
- A documented staging hostname before production hostname cutover
- A rollback procedure for DNS changes

**Current state:** no domain purchase or DNS change. Development may use localhost or a temporary provider URL. Do not place customer data behind a public URL until TLS, authentication, and tenant-isolation checks pass.

## 3. Email provider

Email is not required for the current build. The control plane should keep link-only invitations as the safe default until an email provider is selected and verified.

A future provider must support:

- SMTP or a transactional email API
- Verified sender identity and domain authentication
- Password-reset and invitation templates
- Delivery and bounce monitoring
- Rate limits suitable for onboarding

**Current state:** outbound email disabled. Never put an email API key or SMTP password in source control.

## 4. Stripe

Stripe live billing is intentionally disabled. The current data model may represent plans and subscriptions, but it must not create live charges, subscriptions, invoices, payment methods, or customer billing actions.

Future Stripe work requires separate approval for:

- Test-mode implementation and webhook verification
- Product and price mapping
- Subscription lifecycle handling
- Failed-payment and cancellation behavior
- Customer portal policy
- Live-mode activation

**Current state:** no Stripe account operation, no live key, and no billing side effect.

## 5. Independent backup storage

Provider snapshots alone are not sufficient as the complete backup policy. The future production design should maintain an independent copy of:

- MariaDB logical backups
- Frappe sites and private files
- Configuration and deployment records, excluding secrets
- Backup manifests and integrity checks

Minimum policy:

- Daily backup minimum
- Encrypted storage
- Retention documented before production
- Restore test before acceptance and periodically afterward
- No secret values in logs or backup manifests

**Current state:** backup destination is not selected and no upload or subscription will be created. Local development uses disposable data only.

## 6. Monitoring and alerting

Before production acceptance, monitor at least:

- HTTP availability and latency
- Frontend and backend container state
- MariaDB health and disk usage
- Redis cache and queue health
- Queue-worker activity and failed jobs
- Scheduler activity
- Websocket connectivity
- Backup success and restore-test results
- Host CPU, memory, storage, and restart events

**Current state:** monitoring design only. During free development, use deterministic local health checks and test logs. Do not connect an alerting subscription or send production notifications yet.

## Development safety rules

1. All values in `.env.example` files are placeholders only.
2. Production secrets are supplied by a host secret manager, never committed.
3. Stripe remains disabled unless an explicit production approval is recorded.
4. Email sending remains disabled until a provider and sender identity are verified.
5. No public customer access before HTTPS, backups, monitoring, and tenant isolation are accepted.
6. Paid resources remain outside the current implementation scope.
