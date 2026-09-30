# Cloud SQL PostgreSQL Module

Private-IP Cloud SQL for PostgreSQL with backups, PITR, optional HA, and Secret Manager credential storage.

## Data path

```text
GKE Pod → VPC → Private Service Access → Cloud SQL private IP
```

Public IP is disabled. PSA must exist before this module (Phase 3).

## Secrets

Generates a random DB password and stores:

- `{prefix}-db-password` — raw password
- `{prefix}-db-connection` — JSON with host, port, db, user, password

Never commit these values to Git.
