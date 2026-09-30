# Artifact Registry Module

Creates Docker-format Artifact Registry repositories with optional IAM and cleanup policies.

## Image URL shape

```text
{region}-docker.pkg.dev/{project}/{repo_id}/{image}:{git-sha}
```

Example:

```text
us-central1-docker.pkg.dev/myapp-dev/myapp-dev-frontend/app:a1b2c3d
us-central1-docker.pkg.dev/myapp-dev/myapp-dev-backend/api:a1b2c3d
```

## Auth

GitHub Actions authenticates via Workload Identity Federation → `gha-ci` SA (no JSON keys).
GKE nodes pull via the node SA with `roles/artifactregistry.reader`.
