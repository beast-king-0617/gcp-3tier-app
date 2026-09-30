# Phase 5 — Cloud SQL (Database)

## Why no public IP

Cloud SQL is reachable only via **Private Service Access** inside the environment VPC:

```text
GKE Pod (backend)
  → Pod IP in VPC
  → VPC routing
  → PSA / Service Networking peering
  → Cloud SQL private IP
```

A public IP would expose the database to the internet (even with authorized networks), expand the attack surface, and bypass the private networking model used by GKE nodes. For this architecture, public IP is **disabled**.

## Module

`terraform/modules/cloud-sql` creates:

| Resource | Purpose |
|----------|---------|
| `google_sql_database_instance` | Private PostgreSQL |
| `google_sql_database` | App database (`myapp`) |
| `google_sql_user` | App user (`myapp`) |
| `random_password` | Generated password (not in tfvars) |
| Secret Manager secrets | Password + JSON connection blob |

## Per-environment posture

| Setting | Dev | Stage | Prod |
|---------|-----|-------|------|
| Tier | `db-custom-1-3840` | `db-custom-2-7680` | `db-custom-4-15360` |
| HA | ZONAL | REGIONAL | REGIONAL |
| Disk | 20 GB | 50 GB | 100 GB |
| Deletion protection | false | true | true |
| PITR | yes | yes | yes (14d logs) |
| Backups retained | 7 | 14 | 30 |

## Secrets (never in Git)

| Secret ID | Contents |
|-----------|----------|
| `{app}-{env}-db-password` | Raw password |
| `{app}-{env}-db-connection` | JSON: host, port, database, user, password, sslmode, instance |

Later phases (ESO + Workload Identity) sync these into the `backend` namespace. Phase 5 only creates the secrets.

## SSL

`ssl_mode = ENCRYPTED_ONLY` — clients must use TLS.

## Flags

Only low-noise operational flags by default:

- `log_checkpoints=on`
- `log_lock_waits=on`

Avoid chatty flags like `log_statement=all` in production.

## Dependencies

- Phase 3 PSA (`module.private_service_access`) **must** complete before Cloud SQL private IP assignment
- APIs: `sqladmin.googleapis.com`, `secretmanager.googleapis.com`

## Deploy

Cloud SQL is part of the same environment stack as networking/GKE:

```bash
cd terraform/environments/dev
terraform plan -out=platform.tfplan
terraform apply platform.tfplan
```

## Validate

```bash
./scripts/validate-database.sh dev
terraform output cloudsql_private_ip
terraform output cloudsql_connection_secret_id
# Inspect secret value (authorized humans only):
# gcloud secrets versions access latest --secret=myapp-dev-db-connection
```

## Rollback note (preview)

Application rollback ≠ database rollback. Restoring a Cloud SQL backup/PITR can lose newer writes; coordinate with app version compatibility. Documented fully in Phase 13 DR docs.
