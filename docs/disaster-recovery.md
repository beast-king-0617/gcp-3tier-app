# Disaster Recovery

## Assumptions (v1)

| Metric | Target | Notes |
|--------|--------|-------|
| RPO (app config) | ≈ 0 | Git is source of truth |
| RPO (database) | ≤ 24h (backup) / minutes (PITR) | PITR window per env (7–14 days) |
| RTO (stateless app) | 1–4 hours | Rebuild GKE + Argo sync |
| RTO (database) | 2–8 hours | Restore to new instance + cutover |

v1 is **single-region** (`us-central1`). Multi-region active-active is out of scope.

## Terraform state

1. State bucket has **versioning** + soft-delete (Phase 2).
2. To recover a bad apply:
   ```bash
   gcloud storage objects list gs://BUCKET/env/dev/ --versions
   # Restore prior generation, then terraform init && plan
   ```
3. If the bucket is lost: recreate from bootstrap, restore versioned objects from backup export if configured, or rebuild infra carefully (import / recreate).

## Cloud SQL

1. Automated backups + **PITR** enabled.
2. Restore:
   ```bash
   gcloud sql backups list --instance=INSTANCE
   gcloud sql instances clone SOURCE TARGET --backup-id=ID
   # or point-in-time restore per gcloud sql docs
   ```
3. Update backend ConfigMap `DB_HOST` / Secret Manager connection JSON, then Argo sync.
4. **Database rollback ≠ app rollback** — restoring DB can lose newer writes; coordinate freeze window.

## GKE

1. Cluster is disposable IaC — `terraform apply` recreates.
2. Workloads return via Argo CD from GitOps.
3. Node pool / control plane rebuild RTO dominates; images stay in Artifact Registry.

## Artifact Registry

1. Keep N recent versions (cleanup policy).
2. For DR, retain critical release digests longer in prod (`keep_versions` higher).
3. Rebuild from git SHA if image missing.

## GitOps / Argo CD

1. GitHub is the source of truth — protect `main`/`develop`.
2. Reinstall Argo CD: `enable_argocd=true` terraform apply.
3. Re-point Application to repo URL + path; sync.

## Runbook order (region loss)

1. Create/select DR projects in alternate region (manual redesign — not automated in v1).
2. Restore Cloud SQL PITR/backup to new instance.
3. Apply Terraform env stack (new CIDRs if region differs — plan carefully).
4. Push/sync GitOps; verify Gateway DNS/TLS.
5. Smoke test (`scripts/smoke-test.sh`).
