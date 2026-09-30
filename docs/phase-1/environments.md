# Environment Matrix

## Projects

| Logical env | Variable `project_id` | Billing | Deletion protection |
|-------------|----------------------|---------|---------------------|
| shared | `myapp-shared` | Shared bootstrap costs | State bucket versioning on |
| dev | `myapp-dev` | Dev | Off for most resources |
| stage | `myapp-stage` | Stage | On for SQL |
| prod | `myapp-prod` | Prod | On for SQL, critical resources |

> Replace `myapp-*` with your real project IDs in tfvars. The *logical* names stay `dev` / `stage` / `prod` / `shared`.

## Region

All envs: `us-central1` (variable `region`).

## GKE sizing

| Setting | Dev | Stage | Prod |
|---------|-----|-------|------|
| Cluster | Regional | Regional | Regional |
| Release channel | REGULAR | REGULAR | REGULAR |
| Private nodes | Yes | Yes | Yes |
| Workload Identity | Yes | Yes | Yes |
| Dataplane V2 | Yes | Yes | Yes |
| System pool machine | `e2-standard-2` | `e2-standard-2` | `e2-standard-4` |
| System pool min/max | 1 / 3 | 1 / 3 | 2 / 6 |
| App pool machine | `e2-standard-2` | `e2-standard-4` | `e2-standard-4` |
| App pool min/max | 1 / 5 | 2 / 8 | 3 / 15 |
| Spot/preemptible | Optional for app pool | No | No |

## Cloud SQL sizing

| Setting | Dev | Stage | Prod |
|---------|-----|-------|------|
| Tier | `db-custom-1-3840` | `db-custom-2-7680` | `db-custom-4-15360` |
| HA | No (ZONAL) | Yes (REGIONAL) | Yes (REGIONAL) |
| Disk | 20 GB SSD | 50 GB SSD | 100 GB SSD (+ autosize) |
| Backups | Daily | Daily | Daily |
| PITR | Yes | Yes | Yes |
| Deletion protection | False | True | True |
| Public IP | Disabled | Disabled | Disabled |
| Maintenance window | Sun 03:00 | Sun 03:00 | Sun 05:00 |

Exact machine tiers may be adjusted in Phase 5 tfvars; relative posture stays.

## Application replicas

| Component | Dev | Stage | Prod |
|-----------|-----|-------|------|
| Frontend replicas | 1 | 2 | 3 |
| Backend replicas | 1 | 2 | 3 |
| Backend HPA min/max | 1 / 3 | 2 / 6 | 3 / 12 |
| PDB | Optional | Yes | Yes |

## DNS hostnames (pattern)

| Env | Hostname |
|-----|----------|
| Dev | `dev.${dns_domain}` |
| Stage | `stage.${dns_domain}` |
| Prod | `${dns_domain}` or `www.${dns_domain}` |

Default documentation value: `dns_domain = "myapp.example.com"` (override in tfvars).

## Promotion path

```text
feature → develop → (dev auto)
                 → stage (explicit promote)
                 → prod (approval gate)
```
