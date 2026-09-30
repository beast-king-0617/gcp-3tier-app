# Phase 6 — Artifact Registry

## Repositories

Per environment, Terraform creates two Docker repositories:

| Short name | Repository ID | Purpose |
|------------|---------------|---------|
| `frontend` | `{app}-{env}-frontend` | React/NGINX images |
| `backend` | `{app}-{env}-backend` | Go API images |

## Image tagging

Immutable **git SHA** tags (never deploy `latest`):

```text
{region}-docker.pkg.dev/{project}/{app}-{env}-frontend/frontend:{git-sha}
{region}-docker.pkg.dev/{project}/{app}-{env}-backend/backend:{git-sha}
```

## Authentication (no JSON keys)

```text
GitHub Actions
  → OIDC
  → Workload Identity Federation (Phase 2)
  → gha-ci@{project}.iam.gserviceaccount.com
  → roles/artifactregistry.writer (repo IAM + project role from bootstrap)
```

GKE nodes pull via `gke-nodes` SA with `roles/artifactregistry.reader`.

## Cost controls

Cleanup policy keeps the N most recent versions (dev 20 / stage 30 / prod 50).

## Vulnerability scanning

Repositories inherit / enable Artifact Analysis scanning. CI (Phase 9) also runs Trivy before push/promote.

## Deploy

Part of the environment stack:

```bash
cd terraform/environments/dev
terraform apply
terraform output artifact_registry_urls
```

## Validate

```bash
./scripts/validate-artifact-registry.sh dev
```
