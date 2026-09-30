# Application

Three-tier demo application for the GCP reference platform.

```text
application/
├── frontend/   # React + NGINX
└── backend/    # Go REST API + PostgreSQL
```

Kubernetes base manifests live in `gitops/apps/` (consumed by Argo CD later).

See [docs/phase-7/application.md](../docs/phase-7/application.md).
