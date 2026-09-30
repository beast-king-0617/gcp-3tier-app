# Phase 9 — GitHub Actions / CI

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `docker-build.yml` | reusable | Build, Trivy scan, WIF push to Artifact Registry |
| `frontend-ci.yml` | PR / push / dispatch | npm build + image + GitOps tag bump |
| `backend-ci.yml` | PR / push / dispatch | go test + image + GitOps tag bump |
| `terraform-plan.yml` | PR | fmt, validate, Checkov, plan (tf-planner SA) |
| `terraform-apply.yml` | main/develop + dispatch | apply with GitHub Environment protection (tf-applier SA) |

## Authentication (no JSON keys)

```text
permissions:
  id-token: write
  contents: read

google-github-actions/auth
  → Workload Identity Federation
  → gha-ci / tf-planner / tf-applier
```

## Repository variables (Settings → Variables)

| Variable | Example |
|----------|---------|
| `WIF_PROVIDER` | `projects/123/locations/global/workloadIdentityPools/github-actions/providers/github` |
| `GHA_CI_SERVICE_ACCOUNT` | `gha-ci@myapp-dev.iam.gserviceaccount.com` |
| `TF_PLANNER_SERVICE_ACCOUNT` | `tf-planner@myapp-dev.iam.gserviceaccount.com` |
| `TF_APPLIER_SERVICE_ACCOUNT` | `tf-applier@myapp-dev.iam.gserviceaccount.com` |
| `GCP_PROJECT_ID` | `myapp-dev` |
| `GCP_REGION` | `us-central1` |
| `AR_FRONTEND_REPOSITORY` | `myapp-dev-frontend` |
| `AR_BACKEND_REPOSITORY` | `myapp-dev-backend` |

Use GitHub **Environments** (`dev`, `stage`, `prod`) with environment-scoped variables for multi-env. Protect `prod` with required reviewers.

## Image tags

Immutable: **12-char git SHA**. Never deploy `latest`.

## GitOps update

On successful push to `develop`/`main` (or workflow_dispatch), CI patches `gitops/environments/<env>/kustomization.yaml` image `newTag` and commits. Argo CD (Phase 10) reconciles — CI never runs `kubectl apply`.

## PR checks

- Backend: gofmt, vet, test, gitleaks, docker build+trivy (no push)
- Frontend: npm build, gitleaks, docker build+trivy (no push)
- Terraform: checkov, gitleaks, fmt, validate, plan

## Production approval

`terraform-apply` and prod image deploys use GitHub Environment `prod` → required reviewers.
