# Phase 10 — Argo CD / GitOps CD

## Delivery flow

```text
GitHub Actions (Phase 9)
  → pushes image :git-sha
  → commits gitops/environments/<env>/kustomization.yaml
       ↓
Argo CD (this phase)
  → syncs path gitops/environments/<env>
  → applies Gateway + frontend + backend to GKE
```

CI never runs `kubectl apply` for applications.

## Install

1. Ensure GKE is healthy (`enable_argocd = false` on first platform apply).
2. Set `argocd_git_repo_url` to your Git HTTPS URL.
3. Set `enable_argocd = true` and apply:

```bash
cd terraform/environments/dev
# edit terraform.tfvars
terraform apply
terraform output argocd_access_hint
```

Argo CD is installed with Helm chart `argo-cd` into namespace `argocd`, scheduled on the **system** node pool.

## Sync policy

| Setting | Value |
|---------|-------|
| automated | yes |
| prune | yes |
| selfHeal | yes |
| CreateNamespace | yes |
| ServerSideApply | yes |

## Manifests

| Path | Role |
|------|------|
| `terraform/modules/argocd` | Helm install + AppProject + Application |
| `gitops/argocd/*.yaml` | Reference AppProject/Applications (optional App-of-Apps) |
| `gitops/environments/<env>` | Desired cluster state |

## Private Git repos

If the GitOps repo is private, create a repo credential in Argo CD (SSH deploy key or GitHub App) after install:

```bash
argocd repo add https://github.com/ORG/REPO.git --username git --password "$GITHUB_TOKEN"
```

Do not commit tokens.

## Validate

```bash
./scripts/validate-argocd.sh dev
```
