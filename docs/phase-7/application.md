# Phase 7 — Application

## Components

| Tier | Stack | Port | Image |
|------|-------|------|-------|
| Frontend | React (Vite) + NGINX unprivileged | 8080 | `{ar}/frontend:{sha}` |
| Backend | Go 1.22 + lib/pq | 8080 | `{ar}/backend:{sha}` |
| Data | Cloud SQL PostgreSQL `users` table | 5432 | managed |

## Backend APIs

| Method | Path | Behavior |
|--------|------|----------|
| GET | `/health` | Process up |
| GET | `/ready` | DB ping |
| GET | `/api/v1/version` | App version |
| GET | `/api/v1/users` | List seeded users |

On startup the backend migrates `users` and seeds three demo rows.

## Frontend

- Loads `/api/v1/version` and `/api/v1/users`
- `VITE_API_BASE_URL` empty ⇒ same-origin (Gateway routes `/api` → backend)
- Brand-forward simple UI

## Security (containers + pods)

- Non-root images (distroless / nginx-unprivileged)
- `runAsNonRoot`, drop ALL caps, no privilege escalation
- Read-only root FS + emptyDir where NGINX needs write
- Requests/limits, startup/readiness/liveness probes
- Backend HPA + PDBs

## Secrets

DB password is synced by **ExternalSecret** from Secret Manager (Phase 12).
Set `DB_HOST` in env overlays from `terraform output -raw cloudsql_private_ip`.
Never commit real passwords.

## Build locally

```bash
# Backend
cd application/backend && go test ./... && docker build -t backend:local .

# Frontend
cd application/frontend && npm install && npm run build && docker build -t frontend:local .
```

## GitOps base

```text
gitops/apps/frontend/   # Deployment, Service, PDB, NetworkPolicy, Kustomize
gitops/apps/backend/    # Deployment, Service, HPA, PDB, ExternalSecret, NetworkPolicy
gitops/apps/namespaces.yaml
```

Environment overlays, Gateway, and Argo CD are in Phases 8/10.
