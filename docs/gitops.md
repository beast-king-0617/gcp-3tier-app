# GitOps

Desired Kubernetes state lives under `gitops/`.

```text
gitops/
├── apps/                 # Base workloads (frontend, backend)
├── infrastructure/       # Gateway API, health checks
├── environments/         # Per-env Kustomize overlays
└── argocd/               # AppProject + Application examples
```

## Promotion

1. CI builds immutable images (`:git-sha`)
2. CI updates `environments/<env>/kustomization.yaml` image tags
3. Argo CD auto-syncs (prune + selfHeal)

## Rollback

```bash
git revert <commit>   # or reset image newTag to previous SHA
git push              # Argo CD self-heals to previous desired state
```

See [phase-10/argocd.md](./phase-10/argocd.md).
