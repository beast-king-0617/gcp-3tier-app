# Phase 2 Validation

## Static checks (no GCP apply required)

```bash
cd /Users/shivkumar/Desktop/SOJERN/gcp-3tier-platform
chmod +x scripts/validate-bootstrap.sh
./scripts/validate-bootstrap.sh
```

Expected: `terraform fmt` clean, `terraform validate` succeeds after `init -backend=false`.

## Live checks (after apply)

```bash
cd terraform/bootstrap
terraform output state_bucket_name
terraform output workload_identity_provider
terraform output service_accounts
terraform output iam_role_rationale
```

```bash
SHARED=$(terraform output -raw shared_project_id)
BUCKET=$(terraform output -raw state_bucket_name)

gcloud storage buckets describe "gs://${BUCKET}" --project="${SHARED}"
gcloud iam workload-identity-pools describe github-actions \
  --location=global --project="${SHARED}"
```

## Expected resources created

| Resource | Name pattern |
|----------|--------------|
| GCS bucket | `var.state_bucket_name` |
| WIF pool | `github-actions` |
| WIF provider | `github` |
| SAs × 3 envs | `tf-planner`, `tf-applier`, `gha-ci` |
| Project services | Shared + env API enablement |

## Common errors and fixes

Documented in `terraform/bootstrap/README.md`.
