# Assumptions and Prerequisites

These are enterprise-grade defaults used so Phase 1 can lock design without blocking questions.

## Organizational assumptions

1. You have a GCP organization (or folder) and billing account.
2. Four projects will exist (or be creatable): `myapp-shared`, `myapp-dev`, `myapp-stage`, `myapp-prod` — **real IDs may differ**; map them in tfvars.
3. A human admin can run the **bootstrap** once with sufficient permissions (Project Creator or pre-created projects + Owner/Editor on those projects for bootstrap only).
4. GitHub Organization (or user) can host three repos and configure Environments with required reviewers for `prod`.
5. A public DNS domain you control will be pointed to Cloud DNS / LB (variable `dns_domain`).
6. Primary region is `us-central1`.
7. App short name is `myapp` (resource name prefix).
8. Multi-region active-active is **out of scope** for v1; DR is rebuild + backup restore.
9. Shared VPC is **out of scope** for v1; per-env VPCs.
10. Cost alerts and budgets are recommended but configured lightly in monitoring phase.

## Tooling versions (target)

| Tool | Version posture |
|------|-----------------|
| Terraform | `~> 1.9` |
| Google provider | `~> 6.0` |
| kubectl | matching GKE minor |
| Helm | `v3.x` (Argo CD install) |
| Go | `1.22+` |
| Node.js | `20 LTS` (frontend build) |

## What Phase 1 does *not* create

No GCP resources are provisioned in Phase 1. Only design documentation and repository scaffolding.
