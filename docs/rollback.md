# Rollback Strategy

## Application (GitOps)

```bash
# Revert the GitOps commit that bumped image tags
git revert <commit>
git push
# Argo CD self-heals to previous manifests
```

Or set `newTag` back to a known-good SHA in `gitops/environments/<env>/kustomization.yaml`.

## Container

Deploy a previous **immutable** image tag (`:abc123def456`). Never rely on `:latest`.

## Infrastructure (Terraform)

1. Prefer forward-fix with a new PR.
2. If needed, restore prior state object generation, then `terraform plan`.
3. Avoid `terraform destroy` in prod without a written plan.

## Database

DB rollback is **different**:

| App rollback | DB rollback |
|--------------|-------------|
| Instant, reversible via Git | Risk of data loss |
| No user data rewrite | Restores older data |
| Safe anytime | Needs maintenance window |

Prefer **forward migrations**. Use PITR only for corruption/accidental DELETE with explicit approval.

## Gateway / DNS

DNS TTL is 300s — rollback of A records propagates in minutes. Cert maps stay attached to hostname.
