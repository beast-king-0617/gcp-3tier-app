# Phase 1 Validation Checklist

Phase 1 is design-only. Validate by review, not `terraform apply`.

## Review checklist

- [ ] Environments `dev` / `stage` / `prod` / `shared` understood
- [ ] Project ID naming (`myapp-*`) accepted or mapped to real IDs in notes
- [ ] Region `us-central1` accepted
- [ ] CIDR tables reviewed for no overlap with existing corporate networks
- [ ] Gateway API (not Ingress) accepted
- [ ] Go + React/NGINX accepted
- [ ] External Secrets + Secret Manager accepted
- [ ] Separate GitOps repo + Argo CD accepted
- [ ] WIF / no JSON keys accepted
- [ ] DNS domain will be supplied later via `dns_domain` variable

## Conflict check against your org

If you already use any of these ranges elsewhere (VPN, Shared VPC, interconnect), flag before Phase 3:

```text
10.10.0.0/16  (dev)
10.20.0.0/16  (stage)
10.30.0.0/16  (prod)
172.16.0.0/28, 172.16.0.16/28, 172.16.0.32/28  (GKE masters)
```

## Expected output of Phase 1

```text
gcp-3tier-platform/
├── README.md
└── docs/
    ├── architecture.md
    ├── networking.md
    ├── security.md
    ├── cicd.md
    └── phase-1/
        ├── assumptions.md
        ├── architecture-diagram.md
        ├── cidr-plan.md
        ├── decisions.md
        ├── environments.md
        ├── target-tree.md
        └── validation.md
```

## Common “errors” (design)

| Issue | Fix |
|-------|-----|
| Corporate VPN already uses `10.10.0.0/16` | Remap env supernets in `cidr-plan.md` before Phase 3 |
| Cannot create four projects | Pre-create projects; bootstrap only configures IAM/state/WIF |
| No public domain yet | Keep `dns_domain` variable; use nip.io / temporary hostname only for early smoke tests in later phases |
| Must use Shared VPC | Defer redesign; current ADRs assume per-env VPC |

## Commands (documentation hygiene only)

```bash
cd /Users/shivkumar/Desktop/SOJERN/gcp-3tier-platform
find docs -type f | sort
```

No GCP credentials required for Phase 1.
