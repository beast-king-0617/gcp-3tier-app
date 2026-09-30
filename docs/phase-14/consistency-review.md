# Phase 14 — Consistency Review

Review date: implementation freeze after Phases 1–13.

## Static validation results

| Check | Result |
|-------|--------|
| `terraform validate` bootstrap + dev/stage/prod | Pass |
| `kubectl kustomize` all env overlays | Pass |
| `go test ./...` backend | Pass |
| `./scripts/validate-all.sh dev` | Pass (static) |

## Issues found and disposition

| Area | Finding | Disposition |
|------|---------|-------------|
| Secrets in Git | Old `secret.yaml` placeholder | **Fixed in Phase 12** — ExternalSecret only |
| Stale Phase 7 docs | Still referenced `secret.yaml` | **Fixed in Phase 14** |
| `DB_HOST` | Only in base ConfigMap | **Fixed** — env overlay patches for all envs |
| `REPLACE_*` tokens | Intentional until apply/CI | Documented; CI/GitOps replace image tags; operators replace IP/hostname/cert from TF outputs |
| `policies/` empty | Listed in Phase 1 tree | **Added** README placeholder; Checkov covers TF in CI |
| Terraform ↔ GitOps project IDs | Hard-coded `myapp-*` in overlays | By design — update overlays when real project IDs differ |
| Argo CD / ESO | Default `enable_*=false` | Intentional — enable after GKE healthy |
| Master authorized networks | Empty CIDR list locks kubectl | Documented; operators must add IPs |
| Frontend `VITE_API_BASE_URL` | Build-time empty | Correct for same-origin Gateway `/api` |
| Module IAM breadth | `tf-applier` has many admin roles | Documented; not Owner/Editor; protect via GitHub Environment |

## Remaining operator actions (not code defects)

1. Create real GCP projects and fill `terraform.tfvars`
2. Delegate DNS NS from `dns_name_servers` output
3. Set GitHub Actions variables from WIF outputs
4. Set `enable_argocd` / `enable_external_secrets` true after GKE
5. Patch `DB_HOST`, Gateway IP/certmap (or rely on env kustomize values matching TF naming)
6. Run `./scripts/smoke-test.sh` against live HTTPS URL

## Dependency graph (correct)

```text
bootstrap → state + WIF
env: project-services → network → nat + firewall + psa
     → gke (needs network/nat/firewall)
     → cloud_sql (needs psa)
     → artifact_registry (needs gke node SA for reader binding)
     → dns → certificates
     → app_identity (needs cloud_sql secret ids)
     → monitoring (needs gke + sql)
     → argocd / external_secrets (optional, needs gke)
```

## CIDR conflicts

None within design. Confirm corporate VPN does not use `10.10/16`, `10.20/16`, `10.30/16`, or GKE master `172.16.0.0/28+`.

## Security gaps (accepted for v1)

- CMEK optional (Google-managed encryption default)
- Binary Authorization disabled (can enable later)
- Argo CD server insecure TLS flag for bootstrap UI (terminate TLS at Gateway/IAP later)
- Multi-region DR is documentation-only

## Production readiness

Use [production-readiness.md](../production-readiness.md) checklist after live smoke test.
