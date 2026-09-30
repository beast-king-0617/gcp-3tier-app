# Phase 2 — Terraform Bootstrap

Bootstrap creates the shared foundation that every later phase depends on:

1. Enabled APIs (shared + environment projects)
2. GCS remote state bucket
3. Per-environment automation service accounts
4. Project IAM (least privilege, documented)
5. GitHub Workload Identity Federation (OIDC → Google SA)

## Directory layout

```text
terraform/
├── bootstrap/           # This stack (apply once with privileged human creds)
└── modules/
    ├── project-services/
    └── workload-identity/
```

## The bootstrap problem

Terraform remote state needs a GCS bucket, but the bucket is itself managed by Terraform.

**Solution used here:**

```text
1. Run bootstrap with LOCAL state (backend block commented in terraform.tf)
2. Bootstrap creates the GCS bucket + IAM + WIF
3. Uncomment / add GCS backend (see backend.gcs.tf.example)
4. terraform init -migrate-state   # moves local state into GCS
5. All future environment stacks use the GCS backend from day one
```

Never delete the state bucket without a recovery plan. Versioning + soft-delete are enabled.

## Prerequisites

1. Four GCP projects exist: shared + dev + stage + prod (IDs match your tfvars).
2. Your user can enable APIs and create IAM/SA/storage in those projects
   (typically `roles/owner` or equivalent **for bootstrap only**).
3. Tools installed:
   - Terraform >= 1.9
   - Google Cloud SDK (`gcloud`) authenticated
4. Copy `terraform.tfvars.example` → `terraform.tfvars` and edit real IDs.

```bash
gcloud auth application-default login
gcloud config set project YOUR_SHARED_PROJECT_ID
```

## Deploy

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

terraform fmt -recursive
terraform init
terraform validate
terraform plan -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
```

### Migrate state to GCS

```bash
# Record bucket name
terraform output -raw state_bucket_name

# Create backend.tf from the example (uncomment and set bucket)
cp backend.gcs.tf.example backend.tf
# edit backend.tf

terraform init -migrate-state
# Confirm "yes" to copy local state to GCS
```

## Validate

```bash
../../scripts/validate-bootstrap.sh
```

Or manually:

```bash
terraform output
gcloud storage buckets describe "gs://$(terraform output -raw state_bucket_name)" --format=json
gcloud iam workload-identity-pools list --location=global --project="$(terraform output -raw shared_project_id)"
```

### Expected outputs

| Output | Example shape |
|--------|----------------|
| `state_bucket_name` | `myapp-shared-tfstate` |
| `workload_identity_provider` | `projects/123/locations/global/workloadIdentityPools/github-actions/providers/github` |
| `service_accounts["dev"].tf_planner` | `tf-planner@myapp-dev.iam.gserviceaccount.com` |

## File reference

| File | Purpose | Depends on |
|------|---------|------------|
| `terraform.tf` | Version pins; documents backend migration | — |
| `providers.tf` | Google providers → shared project | variables |
| `variables.tf` | Input contract | — |
| `locals.tf` | API lists, IAM role sets, WIF binding maps | variables, SAs |
| `apis.tf` | Enables APIs via `project-services` module | modules/project-services |
| `state-bucket.tf` | GCS state bucket + IAM | APIs, SAs |
| `service-accounts.tf` | tf-planner, tf-applier, gha-ci per env | APIs |
| `iam.tf` | Project role bindings | SAs, locals |
| `wif.tf` | GitHub OIDC pool/provider + impersonation | modules/workload-identity, SAs |
| `outputs.tf` | Values needed by CI and later phases | all |

## IAM rationale (summary)

| SA | Why these roles |
|----|-----------------|
| `tf-planner` | `viewer` + `securityReviewer` to plan; `storage.objectAdmin` on state bucket for locks |
| `tf-applier` | Admin roles **scoped per service** (compute, container, sql, …) plus `projectIamAdmin` to manage IAM — **not** `roles/owner` |
| `gha-ci` | Artifact Registry read/write only |

Full map: `terraform output iam_role_rationale`

## Common errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Error 403: Caller does not have permission` | ADC user lacks permission on project | Grant Owner/Editor temporarily for bootstrap; use correct project IDs |
| `Error 409: bucket already owns...` / name not available | GCS bucket names are global | Change `state_bucket_name` |
| `Service net... not enabled` | API enable race | Re-run apply; modules wait on `project-services` |
| WIF provider condition rejects tokens | Wrong `github_organization` / repo names | Match exact GitHub org and `org/repo` strings |
| `google_service_account` 404 project | Env project ID typo or no access | Fix `environments.*.project_id` |

## What Phase 2 does NOT create

- VPC / GKE / Cloud SQL / Artifact Registry repositories (later phases)
- GitHub Actions workflow files (Phase 9) — outputs are ready for them
- Environment Terraform stacks under `environments/dev|stage|prod`

## Next phase

Phase 3 — Networking (VPC, subnets, NAT, firewall, PSA) using remote state in this bucket.
