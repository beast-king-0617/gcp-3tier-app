# CI/CD and Branching Strategy (Phase 1)

## 1. Repositories

| Repo | Branch roles |
|------|--------------|
| `myapp-terraform` | Infra changes |
| `myapp-application` | App source + Dockerfiles |
| `myapp-gitops` | Desired K8s state (Kustomize) |

During local development in this workspace they live under `gcp-3tier-platform/` as directories; GitHub Actions paths will match when split.

---

## 2. Branching Model

```text
main          ← production-ready; protected
develop       ← integration (app + terraform)
feature/*     ← short-lived feature work
release/*     ← optional release stabilization
hotfix/*      ← prod fixes branched from main
```

### Flow

1. Developer creates `feature/*` from `develop` (app/terraform) or from `main` for hotfixes.
2. Open PR → required checks must pass.
3. Merge to `develop` → deploy to **dev** automatically (images + GitOps update; Argo syncs).
4. Promote to **stage** via PR or controlled merge updating stage GitOps overlay / workflow dispatch.
5. Promote to **prod** via PR into `main` / GitOps prod overlay with **environment approval**.

---

## 3. Required Checks (PR)

| Check | Terraform repo | Application repo | GitOps repo |
|-------|----------------|------------------|-------------|
| fmt / lint | terraform fmt, tflint | golangci-lint / eslint | kubeconform / kustomize build |
| validate | terraform validate | unit tests | kustomize build all envs |
| security | Checkov, gitleaks | Trivy fs, gitleaks | gitleaks |
| plan | terraform plan (dev) | docker build (no push) | — |
| review | CODEOWNERS | CODEOWNERS | CODEOWNERS |

---

## 4. Main / Protected Branch Behavior

| Event | Action |
|-------|--------|
| Merge to `develop` (app) | Build → scan → push SHA image → update GitOps `environments/dev` |
| Promote stage | Workflow dispatch or merge updates `environments/stage` image digests |
| Merge affecting prod GitOps / `main` | Requires GitHub Environment approval → Argo CD syncs prod |
| Terraform apply prod | Separate workflow with approval; never auto-apply from PR |

---

## 5. Image Tagging

- Tag: full git SHA (immutable)
- Also push digest reference
- **Never** rely on `latest` for deploy
- GitOps manifests pin `image: ...@sha256:...` or `:gitsha`

---

## 6. Authentication

```text
GitHub Actions
   → OIDC token (permissions: id-token: write)
   → GCP Workload Identity Federation
   → Impersonate short-lived Google SA
   → Artifact Registry / Terraform
```

No SA JSON keys in GitHub Secrets.

Implemented workflows: see [phase-9/cicd.md](./phase-9/cicd.md).

---

## 7. Separation of Duties

| Concern | Owner mechanism |
|---------|-----------------|
| What runs in cluster | GitOps commit (reviewed) |
| What infra exists | Terraform apply (approved) |
| Who can push images | `gha-ci` SA via WIF |
| Who can apply prod infra | `tf-applier` + GitHub env approvers |
