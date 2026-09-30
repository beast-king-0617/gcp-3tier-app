# Argo CD Module

Installs Argo CD via Helm into GKE and optionally bootstraps the root Application for this environment.

## Notes

- Schedules on the **system** node pool (`CriticalAddonsOnly` toleration + `role=system` nodeSelector).
- GitOps path defaults to `gitops/environments/<environment>`.
- Repo URL must be reachable from the cluster (public HTTPS, or configure a repo secret / deploy key separately for private repos).
